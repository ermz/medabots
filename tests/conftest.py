import pytest
from brownie import accounts, medabots, erc721

@pytest.fixture()
def alice(accounts):
    return accounts[0]

@pytest.fixture()
def bob(accounts):
    return accounts[1]

@pytest.fixture()
def charles(accounts):
    return accounts[2]

@pytest.fixture()
def _erc721(alice):
    _erc721 = erc721.deploy("MEDA", "Medarotto, fighting robots", {"from": alice})
    return _erc721

@pytest.fixture()
def _medabots(_erc721, alice):
    _medabots = medabots.deploy(_erc721, {"from": alice})
    _erc721.reassignMinter(_medabots, {"from": alice})
    return _medabots

@pytest.fixture()
def mint_medabots(_medabots, alice, bob, charles):
    _medabots.createMedabot("Banisher", 2, 5, {"from": bob, "value": "1 ether"})
    _medabots.createMedabot("Megaphant", 6, 8, {"from": charles, "value": "1 ether"})
    return _medabots