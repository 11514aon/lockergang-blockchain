// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title Store_N_Rent
 * @dev Store and rent items
 */
contract Lockergang {
    struct Item {
        uint256 id;
        string name;
        address owner;
        string status;
        address rentedBy;
    }
    
    mapping(uint256 => Item) public items;
    
    uint256 public itemCount;

    /**
     * @dev constructor
     */
    constructor() {
        itemCount = 0;
        console.log("Deploy by:", msg.sender);
        items[itemCount] = Item(itemCount, "Initial item", msg.sender, "owner", address(0));
    }
    /**
     * เพิ่มสิ่งของเข้าคลัง
     * @dev Add a new item
     * @param _name ชื่อของสิ่งของ
     */
    function addItem(string memory _name) public {
        items[itemCount] = Item(itemCount, _name, msg.sender, "owner", address(0));
        itemCount += 1;
    }
    
    /**
     * @dev Transfer ownership of an item to a new owner
     * @param _itemId IDสิ่งของ
     * @param _newOwner  เจ้าของคนใหม่
     */
    function transferItem(uint256 _itemId, address _newOwner) public {
        require(items[_itemId].owner == msg.sender, "Only owner of this item can transfer");
        items[_itemId].owner = _newOwner;
        items[_itemId].status = "owner";
        items[_itemId].rentedBy = address(0);
    }
    
    /**
     * @dev Rent an item
     * @param _itemId IDสิ่งของ
     */
    function takeItem(uint256 _itemId) public {
        require(items[_itemId].owner != address(0), "Wrong item ID");
        address itemOwner = items[_itemId].owner;
        require(itemOwner != msg.sender, "You are the owner of this item");

        items[_itemId].status = "rented";
        items[_itemId].rentedBy = msg.sender;

        emit ItemTaken(_itemId, itemOwner, msg.sender);
    }
    event ItemTaken(uint256 indexed itemId, address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Return a rented item to its owner
     * @param _itemId IDสิ่งของ
     */
    function returnItem(uint256 _itemId) public {
    require(items[_itemId].owner != msg.sender, "you can not return your own item");
    require(keccak256(abi.encodePacked(items[_itemId].status)) == keccak256(abi.encodePacked("rented")), "The item is not currently rented");
    require(items[_itemId].rentedBy == msg.sender, "Only the current renter can return the item");

    address itemOwner = items[_itemId].owner;
    items[_itemId].status = "owner";
    items[_itemId].rentedBy = address(0);

    emit ItemReturned(_itemId, itemOwner, msg.sender);
}
    event ItemReturned(uint256 indexed itemId, address indexed owner, address indexed renter);
    /**
     * @dev Owner delete own item
     * @param _itemId IDสิ่งของ
     */
    function deleteItem(uint256 _itemId) public {
    require(items[_itemId].owner == msg.sender, "Only the owner can delete the item");
    
    itemCount -= 1;
    delete items[_itemId];
    emit ItemDeleted(_itemId, msg.sender);
}
    event ItemDeleted(uint256 indexed itemId, address indexed owner);
}
