/* 	DEROMultisig
	Multisig concept implementation on DVM-BASIC  
	by @plrspro
*/

/* Service Functions and Utility */

Function Initialize() Uint64
	
	999 RETURN Info("Contract Successfully Deployed")
End Function 


Function Info(info_message String) Uint64 

	10  PRINTF("  +-------------------+  ")
	20  PRINTF("  |   DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+info_message       )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-------------------+  ")
	
	999 RETURN 0
End Function 


Function Error(error_message String) Uint64 

	10  PRINTF("  +-----[ ERROR ]-----+  ")
	20  PRINTF("  |   DEROMultisig    |  ")
	30  PRINTF("  |                   |  ")
	40  PRINTF("  | "+error_message       )
	50  PRINTF("  |                   |  ")
	60  PRINTF("  +-----[ ERROR ]-----+  ")
	
	999 RETURN 1
End Function 


/* `DEROMultisig Wallet` Specific Functions */

// Creates unlocked `DEROMultisig Wallet` instance (txid represents your wallet id inside of a contract scope)
Function WalletCreate()

	DIM wallet as String
	LET wallet = TXID()
	
	STORE(wallet, SIGNER()) //Your wallet address
	STORE(wallet+'_locked', 0) //Flag that locks wallet wich allow deposits and disables adding another signers
	
	999 RETURN Info("New `DEROMultisig Wallet` successfully created. Wallet id: "+wallet)
End Function


// Add signer to `DEROMultisig Wallet`
Function WalletAddSigner(wallet, signer)
	
	// Check if given `DEROMultisig Wallet` instance exists in database
	10 IF EXISTS(wallet) THEN GOTO 
	11 RETURN Error("Given `DEROMultisig Wallet` instance exists in database")
	
	//Signer cannot be added to locked wallet
	DIM raw_signer_adress as String
	DIM signer_index as Uint64
	
	LET raw_signer_adress = ADDRESS_RAW(signer_adress)
	LET signer_index = LOAD(TXID()+'_signer_index')
	
	IS_ADDRESS_VALID(raw_signer_adress)
	STORE(TXID()+'_signer_index', 0)
	STORE(TXID()+'_signer_0', raw_signer_adress)
	
	999 RETURN 0
End Function


//Locks `DEROMultisig Wallet` preventing new signers to be added to this wallet and allows deposits
Function WalletLock(wallet)
	
	//Check if wallet exists
	10 IF EXISTS(wallet_adress) THEN GOTO 
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	//Check if wallet exists
	20 IF LOAD(wallet_adress+"_creator') THEN GOTO 
	21 RETURN Error("You have no permission to lock this `DEROMultisig Wallet`")
	
	STORE(TXID()+'_locked', 1)
	
	999 RETURN 0
End Function


/* Wallet Aliases */

Function WalletCreateAndLockWithOneAdditionalSigner()

	IF WalletCreate() == 0 THEN GOTO
	
	999 RETURN 0
End Function


Function WalletCreateAndLockWithTwoAdditionalSigners()


	999 RETURN 0
End Function


Function WalletCreateAndLockWithThreeAdditionalSigners()


	999 RETURN 0
End Function


/* `DEROMultisig Transaction` Specific Functions */

//Deposits are only allowed in locked wallets (If wallet is unlocked value will be transfered back)
Function TransactionDeposit(wallet_adress, value Uint64) Uint64

	//Check if wallet exists
	10 IF EXISTS(wallet_adress) THEN GOTO 
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")

	IF LOAD(TXID()+'_locked') == 1

	999 RETURN 0
End Function


//Creates a `DEROMultisig Transaction`
Function TransactionSend(wallet, transaction)

	//Check if wallet exists
	10 IF EXISTS(wallet) THEN GOTO 100
	11 RETURN Error("Given `DEROMultisig Wallet` does not exists")
	
	//Check if wallet exists
	20 IF EXISTS(transaction) THEN GOTO 100
	21 RETURN Error("Given `DEROMultisig Transaction` does not exists")
	
	100
	
	999 RETURN 0
End Function


//Creates a `DEROMultisig Transaction`
Function TransactionWithdraw()
	
	999 RETURN TransactionSend()
End Function


//Signs a `DEROMultisig Transaction` (when last signer will sign this transaction dero will be withdrawn)
Function TransactionSign()

	SEND_DERO_TO_ADDRESS

	
	999 RETURN 0
End Function
