# @version ^0.2.0

struct Medabot:
    medaId: uint256
    name: String[50]
    generation: uint256
    xGene: int128
    yGene: int128

interface iErc721:
    def reassignMinter(newMinter: address): nonpayable
    def viewTokenOwner(_token_id: uint256) -> address: view
    def viewOwnerCount() -> uint256: view
    def viewIdApprovals(_token_id: uint256) -> bool: view
    def mint(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def transfer(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def approve(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def revokePermission(_addr: address, _tokenId: uint256) -> bool: nonpayable
    def transferFromApproved(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def burn(_tokenId: uint256) -> bool: nonpayable

admin: address
erc721Addr: address

medabots: HashMap[uint256, Medabot]

medabotsForSale: HashMap[uint256, uint256]

medabotsForRent: HashMap[uint256, uint256]

fundsEarned: HashMap[address, uint256]

medabotCounter: uint256

@external
def __init__(_erc721Addr: address):
    self.admin = msg.sender
    self.erc721Addr = _erc721Addr

@external
@view
def viewMedabotsForSale(_medaId: uint256) -> uint256:
    return self.medabotsForSale[_medaId]

@external
@payable
def createMedabot(_name: String[50], _xGene: int128, _yGene: int128):
    assert msg.value > 1, "You need to pay 1 ether in order to create your Medabot"
    assert _xGene <=10 and _yGene <=10, "Your gene traits can't be over 10"
    # Play around with xGene and yGene numbers later
    new_medabot: Medabot = Medabot({
        medaId: self.medabotCounter,
        name: _name,
        generation: 1,
        xGene: _xGene,
        yGene: _yGene
    })
    self.medabots[self.medabotCounter] = new_medabot
    iErc721(self.erc721Addr).mint(msg.sender, self.medabotCounter)
    self.medabotCounter += 1
    
@external
def sellMedabot(_medaId: uint256, price: uint256):
    assert iErc721(self.erc721Addr).viewTokenOwner(_medaId) == msg.sender, "You are not the owner of this medabot"
    self.medabotsForSale[_medaId] = price

@external
@payable
def buyMedabot(_medaId: uint256):
    assert self.medabotsForSale[_medaId] > 0, "This medabot is not for sale"
    assert msg.value > (self.medabotsForSale[_medaId] * 1_000_000_000_000_000_000), "You don't have enough to purchase this medabot"
    assert iErc721(self.erc721Addr).viewIdApprovals(_medaId) == True, "Assert that only this contract can call this function, other than owner"
    previousOwner: address = iErc721(self.erc721Addr).viewTokenOwner(_medaId)
    iErc721(self.erc721Addr).transferFromApproved(msg.sender, _medaId)
    self.medabotsForSale[_medaId] = 0
    self.fundsEarned[previousOwner] += msg.value

@external
@payable
def rentMedapot(_rentalMedaId: uint256, _ownerMedaId: uint256, _name: String[50]):
    assert self.medabotsForRent[_rentalMedaId] > 0, "This medabot is not up for rental"
    assert msg.value >= (self.medabotsForRent[_rentalMedaId] * 1_000_000_000_000_000_000), "Insufficient funds for rental"
    assert iErc721(self.erc721Addr).viewTokenOwner(_rentalMedaId) != msg.sender, "You already own this medabot, you can't loan it"
    assert iErc721(self.erc721Addr).viewTokenOwner(_ownerMedaId) == msg.sender, "You are not the owner of your medabot"
    rentalMedabot: Medabot = self.medabots[_rentalMedaId]
    ownerMedabot: Medabot = self.medabots[_ownerMedaId]
    newXgene: int128 = rentalMedabot.xGene
    newYgene: int128 = ownerMedabot.yGene
    newGeneration: uint256 = 0
    if rentalMedabot.generation > ownerMedabot.generation:
        newGeneration = rentalMedabot.generation + 1
    else:
        newGeneration = ownerMedabot.generation + 1
    
    new_medabot: Medabot = Medabot({
        medaId: self.medabotCounter,
        name: _name,
        generation: newGeneration,
        xGene: newXgene,
        yGene: newYgene
    })
    self.medabots[self.medabotCounter] = new_medabot
    iErc721(self.erc721Addr).mint(msg.sender, self.medabotCounter)
    self.medabotCounter += 1
    self.fundsEarned[iErc721(self.erc721Addr).viewTokenOwner(_rentalMedaId)] += msg.value

@external
def withdrawEarnings():
    assert self.fundsEarned[msg.sender] > 0, "You have nothing to withdraw at the moment"
    send(msg.sender, self.fundsEarned[msg.sender])
    self.fundsEarned[msg.sender] = 0

@external
@payable
def breedMedabot(_medaId1: uint256, _medaId2: uint256, _name: String[50]):
    assert msg.value >= (2 * 1_000_000_000_000_000_000), "You must pay 2 ether to breed medabots"
    assert iErc721(self.erc721Addr).viewTokenOwner(_medaId1) == msg.sender, "Medabot 1 doesn't belong to you"
    assert iErc721(self.erc721Addr).viewTokenOwner(_medaId2) == msg.sender, "Medabot 2 doesn't belong to you"
    medabot_1: Medabot = self.medabots[_medaId1]
    medabot_2: Medabot = self.medabots[_medaId2]
    newXgene: int128 = medabot_1.xGene
    newYgene: int128 = medabot_2.yGene
    new_generation: uint256 = 0
    if medabot_1.generation > medabot_2.generation:
        new_generation = medabot_1.generation
    else:
        new_generation = medabot_2.generation
    
    new_medabot: Medabot = Medabot({
        medaId: self.medabotCounter,
        name: _name,
        generation: new_generation,
        xGene: newXgene,
        yGene: newYgene
    })
    self.medabots[self.medabotCounter] = new_medabot
    iErc721(self.erc721Addr).mint(msg.sender, self.medabotCounter)
    self.medabotCounter += 1