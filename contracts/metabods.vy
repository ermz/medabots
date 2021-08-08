# @version ^0.2.0

struct Metabod:
    metaId: uint256
    name: String[30]
    generation: uint256
    xGene: uint256
    yGene: uint256

interface iErc721:
    def viewTokenOwner(_token_id: address) -> address: view
    def viewOwnerCount() -> uint256: view
    def viewIdApprovals(_token_id: uint256) -> bool: view
    def mint(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def transfer(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def approve(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def revokePermission(_addr: address, _tokenId: uint256) -> bool: nonpayable
    def transferFromApproved(_receiver: address, _tokenId: uint256) -> bool: nonpayable
    def burn(_tokenId: uint256) -> bool: nonpayable

metabods: HashMap[uint256, Metabod]

metabodsToOwner: HashMap[address, uint256]
