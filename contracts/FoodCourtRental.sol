// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FoodCourtRental {
    
    struct Stand {
        uint id;
        string name;
        uint rentalPricePerMonth; // Harga sewa per bulan
        address currentTenant;    // Penyewa saat ini
        uint rentedUntil;         // Timestamp kapan masa sewa berakhir
    }

    address public owner;
    uint public standCount = 0;
    mapping(uint => Stand) public stands;

    event StandAdded(uint id, string name, uint rentalPricePerMonth);
    event StandRented(uint id, address tenant, uint durationInMonths);
    event PaymentReceived(uint id, uint amount, address tenant);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier standAvailable(uint _standId) {
        require(
            stands[_standId].currentTenant == address(0) || 
            stands[_standId].rentedUntil < block.timestamp,
            "Stand is already rented"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fungsi untuk menambahkan stand baru
    function addStand(string memory _name, uint _rentalPricePerMonth) public onlyOwner {
        standCount++;
        stands[standCount] = Stand(standCount, _name, _rentalPricePerMonth, address(0), 0);
        emit StandAdded(standCount, _name, _rentalPricePerMonth);
    }

    // Fungsi untuk menyewa stand
    function rentStand(uint _standId, uint _durationInMonths) public payable standAvailable(_standId) {
        Stand storage stand = stands[_standId];
        uint totalCost = stand.rentalPricePerMonth * _durationInMonths;
        require(msg.value >= totalCost, "Insufficient payment");

        stand.currentTenant = msg.sender;
        stand.rentedUntil = block.timestamp + (_durationInMonths * 30 days);

        emit StandRented(_standId, msg.sender, _durationInMonths);
        emit PaymentReceived(_standId, msg.value, msg.sender);
    }

    // Fungsi untuk mengecek status sewa
    function isStandAvailable(uint _standId) public view returns (bool) {
        Stand storage stand = stands[_standId];
        return stand.currentTenant == address(0) || stand.rentedUntil < block.timestamp;
    }

    // Fungsi untuk menarik dana oleh pemilik
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fungsi fallback untuk menerima ether
    receive() external payable {}
}
