// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract VariableTypes {
    uint sum;

    // Fungsi untuk menambahkan dua angka
    function tambah(uint num1, uint num2) public {
        uint temp = num1 + num2;
        sum = temp;
    }

    // Fungsi untuk mendapatkan hasil penjumlahan
    function getHasil() public view returns (uint) {
        return sum;
    }
}
