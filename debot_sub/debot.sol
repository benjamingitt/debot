pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
// import required DeBot interfaces and basic DeBot contract.
import "../Debot.sol";
import "../Menu.sol"
import "../Terminal.sol";

contract Subscribe is Debot {

    address m_wallet;

    bytes m_icon;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    /// @notice Entry point function for DeBot.
    function start() public override {
        // print string to user.
        Terminal.print(0, "Hello, i'm subscriber bot!");
        // input string from user and define callback that receives entered string.
        _menu();
        
    }

    function _menu() private inline {
        Menu.select("Main menu", "description for menu", [
            MenuItem("Subscriber", "", tvm.functionId(handleMenu1)),
            MenuItem("Unsubscribe", "", tvm.functionId(handleMenu2))
        ]);
    }

    function handleMenu1(uint32 index) public {
        optional(uint256) pubkey = 0;
        Isubscribe(m_wallet).submitTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(m_dest, m_tons, m_bounce, false, m_payload);
    }
    }

        function onConfirmSuccess() public {
        Terminal.print(0, "Transaction confirmed.");
        confirmMenu(0);
    }

        function onError(uint32 sdkError, uint32 exitCode) public {
        // TODO: parse different types of errors: sdkError and exit Code.
        // DeBot can undestand if txn was reejcted by user or if wallet contract throws an exception.
        // DeBot can help user to undestand when keypair is invalid, for example.
        exitCode = exitCode; sdkError = sdkError;
        ConfirmInput.get(m_retryId, "Transaction failed. Do you want to retry transaction?");
    }

    function handleMenu2(uint32 index) public {
        // TODO: continue here
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Subscribe";
        version = "0.2.0";
        publisher = "Radiance";
        caption = "Start develop DeBot from here";
        author = "Radiance";
        support = address.makeAddrStd(0, 0:f52f6e74454263dee8cfea3cc45745e67e27b11a37b2dd342182cbd20dc5d16e);
        hello = "Hello, i am a Subscribe DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID ];
    }


}