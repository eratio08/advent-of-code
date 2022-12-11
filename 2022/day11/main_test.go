package main

import (
	"fmt"
	"math/big"
	"testing"
)

func TestBigInt(t *testing.T) {
	a := big.NewInt(12)
	b := big.NewInt(10)

	fmt.Println(a, a.Mul(a, b), b)
}

func TestRem(t *testing.T) {
	a := big.NewInt(20)
	b := big.NewInt(2)

	fmt.Println(a.Rem(a, b), a.BitLen() == 0)
}
