import pytest
from brownie import accounts
import brownie

def test_create_medabots(_medabots, bob, charles):
    _medabots.createMedabot("Metabee", 8, 7, {"from": bob, "value": "1 ether"})
    assert _medabots.viewMedabot(0)["name"] == "Metabee"
    _medabots.createMedabot("Blackram", 2, 4, {"from": charles, "value": "1 ether"})
    assert _medabots.viewMedabot(1)["generation"] == 1
    with brownie.reverts("Your gene traits can't be over 10"):
        _medabots.createMedabot("Peppercat", 12, 8, {"from": charles, "value": "1 ether"})
    with brownie.reverts("You need to pay 1 ether in order to create your Medabot"):
        _medabots.createMedabot("Phoenix", 1, 2, {"from": bob})

def test_buy_sell_medabots(mint_medabots, bob, charles):
    assert mint_medabots.viewMedabot(0)["name"] == "Banisher"
    with brownie.reverts("This medabot is not for sale"):
        mint_medabots.buyMedabot(0, {"from": charles})
    mint_medabots.sellMedabot(0, 3, {"from": bob})
    with brownie.reverts("You don't have enough to purchase this medabot"):
        mint_medabots.buyMedabot(0, {"from": charles, "value": "2 ether"})
    assert mint_medabots.viewMedabotsForSale(0) == 3
    mint_medabots.buyMedabot(0, {"from": charles, "value": "3 ether"})
    assert mint_medabots.viewMedabotsForSale(0) == 0

def test_rent_medabot(mint_medabots, bob, charles):
    with brownie.reverts("You can't lease out a medabot that isn't yours"):
        mint_medabots.leaseMedabot(0, 4, {"from": charles})
    mint_medabots.leaseMedabot(0, 4, {"from": bob})
    mint_medabots.createMedabot("Kintaro", 5, 7, {"from": charles, "value": "1 ether"})
    mint_medabots.leaseMedabot(2, 3, {"from": charles})
    assert mint_medabots.viewMedabot(2)["name"] == "Kintaro"
    with brownie.reverts("You already own this medabot, you can't loan it"):
        mint_medabots.rentMedabot(2, 1, "MegaKin", {"from": charles, "value": "3 ether"})
    with brownie.reverts("Insufficient funds for rental"):
        mint_medabots.rentMedabot(0, 1, "BanMega", {"from": charles, "value": "2 ether"})
    with brownie.reverts("You are not the owner of your medabot"):
        mint_medabots.rentMedabot(0, 3, "BanMega", {"from": charles, "value": "4 ether"})