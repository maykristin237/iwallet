package com.sevenblock.demowallet;

import com.sevenblock.walletsdk.constant.ChainId;
import com.sevenblock.walletsdk.constant.CoinType;

import java.util.Arrays;
import java.util.List;

public class TestConstants {
    public static boolean testBtc = true;
    public static boolean mainNet = true;
    public static String password = "666666";
    public static String address;
    public static List<String> mnemonics = Arrays.asList("drive inform twist allow machine art busy convince sort toast marriage drum".split(" "));

    public static String getCoinType() {
        return testBtc ? CoinType.BITCOIN : CoinType.ETHEREUM;
    }
    public static String getChainId() {
        return testBtc ? (mainNet ? ChainId.BITCOIN_MAINNET : ChainId.BITCOIN_TESTNET)
                : ChainId.ETHEREUM_MAINNET;
    }
    public static void setTestBtc(boolean tb) {
        testBtc = tb;
    }
    public static void setMainNet(boolean mn) {
        mainNet = mn;
    }
}
