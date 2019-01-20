/* Simpe immutable & censorship resistant chat on DVM-BASIC  
   by @plrspro
*/

/* Service Functions and Utility */

Function Initialize() Uint64
	
	01 STORE("admin_addr",SIGNER())
	02 STORE("room_list_index",0)
	03 STORE("nickname_"+SIGNER(), "Admin")
	
	10 IF HostChat("General") == 0 THEN GOTO 90
	11 RETURN 1
	
	//Add default rooms here if needed
	
	90 RETURN Attention("Chat contract hosted successfully")
	
End Function 


Function Error(error_message String) Uint64 

	10 PRINTF " "
	11 PRINTF "======== CHAT * ERROR ========"
	12 PRINTF "Execution error occured: %s" error_message
	13 PRINTF "========"
	14 PRINTF " "
	15 RETURN 1
	
End Function 


Function Attention(attention_message String) Uint64 

	01 dim scid, requester as String
	02 let scid = SCID();
	03 let requester = SIGNER();
	
	10 PRINTF " "
	11 PRINTF "======== CHAT ========"
	12 PRINTF "= ATTENTION: %s" attention_message
	13 PRINTF "= Contract ID: %s" scid
	14 PRINTF "= Requested by: %s" requester
	15 PRINTF "========"
	16 PRINTF " "
	
	25 RETURN 0
	
End Function 

/* Admin Functions */

Function DelegateAdminRights(newadmin String) Uint64 

	10  IF ADDRESS_RAW(LOAD("admin_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 20 
	11  RETURN Error("Only admins can delegate admin right to other adress")

	20  STORE("tmpadmin_addr", newadmin)
	21  RETURN 0
	
End Function


Function ClaimAdminRights() Uint64 

	10  IF ADDRESS_RAW(LOAD("tmpowner_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 20 
	11  RETURN Error("You are not eligable for claim")

	20  STORE("admin_addr", SIGNER())
	21  RETURN 0
  
End Function


Function HostChat(room_name String) Uint64

	10 IF ADDRESS_RAW(LOAD("admin_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 20
	11 RETURN Error("Only Admin can host rooms")
	
	20 IF EXISTS(room_name+"_index") == 0 THEN GOTO 30
	21 RETURN Error("Room with this name already exists")
	
	30 DIM room_index as Uint64
	31 LET room_index = LOAD("room_list_index")
	32 STORE(room_name+"_index", room_index)
	33 STORE("room_list_"+room_index, room_name)
	34 STORE("room_list_index", room_index+1)
	
	40 Attention("New Chatroom hosted successfully")
	
	41 IF PostMessage(room_name, "Hello World !") == 0 THEN GOTO 45
	42 RETURN 1
	45 IF ViewChatList() == 0 THEN GOTO 95
	46 RETURN 1
	
	95 RETURN 0

End Function 


/* Public Functions */

Function ViewChatList() Uint64

	10 DIM room_index, iteration as Uint64
	11 DIM room_name as String
	12 LET room_index = LOAD("room_list_index")
	13 LET iteration = 0
	
	15 Attention("List of availiable chats")
	
	20 LET room_name = LOAD("room_list_"+iteration)
	21 PRINTF " "
	22 PRINTF "#%d. %s" iteration room_name
	23 PRINTF " "
	24 LET iteration = iteration + 1
	25 IF iteration < room_index THEN GOTO 20
	
	95 RETURN 0

End Function 


Function ViewChat(room_name String) Uint64

	01 DIM iteration, block as Uint64
	02 DIM author, text, nickname as String
	03 LET iteration = 5
	
	15 Attention("Viewing chat room: "+room_name)
	
	//If not exist iterate down to 0
	20 IF EXISTS(room_name+"_message_"+iteration+"_block") == 0 THEN GOTO 32
	
	//Load message
	21 LET author = LOAD(room_name+"_message_"+iteration+"_author")
	22 LET text = LOAD(room_name+"_message_"+iteration+"_text")
	23 LET block = LOAD(room_name+"_message_"+iteration+"_block")
	
	//Load nickane for author if exists
	25 LET nickname = SIGNER()
	26 IF EXISTS("nickname_"+SIGNER()) == 0 THEN GOTO 30
	27 LET nickname = LOAD("nickname_"+SIGNER())
	
	//Print message
	30 PRINTF " "
	31 PRINTF "= [%d] %s: %s" block nickname text
	32 PRINTF " "
	33 LET iteration = iteration - 1
	34 IF iteration > 0 THEN GOTO 20

	35 RETURN 0	
		
End Function 


Function PostMessage(room_name String, message String) Uint64

	01 DIM iteration as Uint64
	02 LET iteration = 5

	20 IF EXISTS(room_name+"_index") == 1 THEN GOTO 25
	21 RETURN Error("Room with this name does not exists")

	25 IF message!="" THEN GOTO 30
	26 RETURN Error("Message should not be empty")
	
	//Pull messages down from bottom up
	30 IF EXISTS(room_name+"_message_"+(iteration-1)+"_block") == 0 THEN GOTO 40

	35 STORE(room_name+"_message_"+(iteration)+"_author",LOAD(room_name+"_message_"+(iteration-1)+"_author"))
	36 STORE(room_name+"_message_"+(iteration)+"_text",LOAD(room_name+"_message_"+(iteration-1)+"_text"))
	37 STORE(room_name+"_message_"+(iteration)+"_block",LOAD(room_name+"_message_"+(iteration-1)+"_block"))
	
	40 LET iteration = iteration - 1
	41 IF iteration == 1 THEN GOTO 70 ELSE GOTO 30

	//Insert as 0 index (first message)
	70 STORE(room_name+"_message_1_author",SIGNER())
	71 STORE(room_name+"_message_1_text",message)
	72 STORE(room_name+"_message_1_block",BLOCK_HEIGHT())
	
	95 RETURN ViewChat(room_name)

End Function 


Function ChangeNickname(new_nickname String) Uint64

	01 IF new_nickname!="" THEN GOTO 10
	02 RETURN Error("Nickname should not be empty")
	
	03 IF new_nickname == "Admin" THEN GOTO 04 ELSE GOTO 10
	04 IF ADDRESS_RAW(LOAD("admin_addr")) == ADDRESS_RAW(SIGNER()) THEN GOTO 10
	05 RETURN Error("Only admins can set the name to Admin")
	
	10 STORE("nickname_"+SIGNER(), new_nickname)
	95 RETURN 0

End Function 
