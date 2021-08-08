# # @version ^0.2.0

# event Transfer:
#     _from: address
#     _to: address
#     _tokenId: uint256

# addrToTokenCount: HashMap[address, uint256]

# tokenToOwner: HashMap[uint256, address]

# approvals: HashMap[uint256, HashMap[address, bool]]

# @external
# @view
# def balanceOf(addr: address) -> uint256:
#     return self.addrToTokenCount[addr]

# @external
# @view
# def ownerOf(_tokenId: uint256) -> address:
#     return self.tokenToOwner[_tokenId]

# @external
# def transfer(_to: address, _tokenId: uint256):
#     assert self.tokenToOwner[_tokenId] == msg.sender, "You must be the owner of the Token"
#     assert _to != ZERO_ADDRESS, "You must send to a real address"
#     self.tokenToOwner[_tokenId] = _to
#     self.addrToTokenCount[msg.sender] -= 1
#     self.addrToTokenCount[_to] += 1

# @external
# def safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: bytes32):
#     assert self.approvals[_tokenId][msg.sender] == True, "You don't have permission to transfer this token"
#     assert self.tokenToOwner[_tokenId] == _from, "Sender doesn't own this token"
#     self.tokenToOwner[_tokenId] = _to
#     self.addrToTokenCount[_from] -= 1
#     self.addrToTokenCount[_to] += 1
#     self.approvals[_tokenId][msg.sender] = False
#     log Transfer(_from, _to, _tokenId)

# @external
# def approve(_to: address, _tokenId: uint256):
#     assert self.tokenToOwner[_tokenId] == msg.sender, "You must own this token, to give other approval"
#     self.approvals[_tokenId][_to] = True

# @version ^0.2.0

_minter: address
ticker: String[4]
description: String[100]

tokenIdToOwner: HashMap[uint256, address]

tokenIdtoApprovals: HashMap[uint256, HashMap[address, bool]]

tokenOwnerCount: HashMap[address, uint256]

# A HashMap for token library, that holds an address -> which leads to an array of every NFT they own
# This could be wrong, I think arrays in Vyper can't be dynamic

@external
def __init__(_ticker: String[4], _description: String[100]):
    self._minter = msg.sender
    self.ticker = _ticker
    self.description = _description

@external
def reassignMinter(newMinter: address):
    assert msg.sender == self._minter, "Only the minter may be able to reassign minter position"
    assert newMinter != ZERO_ADDRESS, "New minter must be a valid address"
    self._minter = newMinter

# Needs change to a more useful function
@external
@view
def viewTokenOwner(_token_id: uint256) -> address:
    return self.tokenIdToOwner[_token_id]

@external
@view
def viewOwnerCount() -> uint256:
    return self.tokenOwnerCount[msg.sender]

@external
@view
def viewIdApprovals(_token_id: uint256) -> bool:
    return self.tokenIdtoApprovals[_token_id][msg.sender]

@external
def mint(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == self._minter, "Only the 'minter' can 'mint', hence why he's the 'minter'."
    assert _receiver != ZERO_ADDRESS, "The reciving address can't be a zero address"
    assert self.tokenIdToOwner[_tokenId] == ZERO_ADDRESS, "A token with this token I.D already exists"

    self.tokenIdToOwner[_tokenId] = _receiver
    self.tokenOwnerCount[_receiver] += 1
    # Set tokenIdToApprovals for minter aswell
    self.tokenIdtoApprovals[_tokenId][msg.sender] = True

    return True

@external
def transfer(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokenIdToOwner[_tokenId], "Must be the owner of token to transfer"
    assert _receiver != ZERO_ADDRESS

    self.tokenIdToOwner[_tokenId] = _receiver
    self.tokenOwnerCount[msg.sender] -= 1
    self.tokenOwnerCount[_receiver] += 1

    return True

@external
def approve(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokenIdToOwner[_tokenId], "Must be owner of token to give approval"
    assert _receiver != ZERO_ADDRESS

    self.tokenIdtoApprovals[_tokenId][_receiver] = True
    return True

@external
def revokePermission(_addr: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokenIdToOwner[_tokenId], "Must be the owner to revoke permission"
    
    self.tokenIdtoApprovals[_tokenId][_addr] = False
    return True

@external
def transferFromApproved(_receiver: address, _tokenId: uint256) -> bool:
    assert True == self.tokenIdtoApprovals[_tokenId][msg.sender], "You don't have approval"
    assert _receiver != ZERO_ADDRESS

    previousOwner: address = self.tokenIdToOwner[_tokenId]

    self.tokenIdToOwner[_tokenId] = _receiver
    self.tokenIdtoApprovals[_tokenId][msg.sender] = False
    self.tokenOwnerCount[previousOwner] -= 1
    self.tokenOwnerCount[_receiver] += 1
    return True

@external
def burn(_tokenId: uint256) -> bool:
    # This checks to see if you are the owner or you have permission
    assert msg.sender == self.tokenIdToOwner[_tokenId], "You must be owner to burn a token"

    originalOwner: address = self.tokenIdToOwner[_tokenId]

    #Have to check if clear function works
    self.tokenIdToOwner[_tokenId] = ZERO_ADDRESS
    self.tokenOwnerCount[originalOwner] -= 1

    return True

