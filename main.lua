-- [ file obfuscated with hesiz obfuscator v2.0.0]
--    __           _   
--   / /  ___ ___ (_)__
--  / _ \/ -_|_-</ /_ /
-- /_//_/\__/___/_//__/



 local Byte         = string.byte;
 local Char         = string.char;
 local Sub          = string.sub;
 local Concat       = table.concat;
 local Insert       = table.insert;
 local LDExp        = math.ldexp;
 local GetFEnv      = getfenv or function() return _ENV end;
 local Setmetatable = setmetatable;
 local Select       = select;
 
 local Unpack = unpack or table.unpack;
 local ToNumber = tonumber;local function decompress(b)local c,d,e="","",{}local f=256;local g={}for h=0,f-1 do g[h]=Char(h)end;local i=1;local function k()local l=ToNumber(Sub(b, i,i),36)i=i+1;local m=ToNumber(Sub(b, i,i+l-1),36)i=i+l;return m end;c=Char(k())e[1]=c;while i<#b do local n=k()if g[n]then d=g[n]else d=c..Sub(c, 1,1)end;g[f]=c..Sub(d, 1,1)e[#e+1],c,f=d,d,f+1 end;return table.concat(e)end;local ByteString=decompress('25X25T27525V26327525T25925A24W25124I24L24J25425B25225V27427525224W25825025V25Y27924924L24L24H24625024L25V25G27925527W24H24I26J27227225525024I25424R27324Y25A25827224J24W24M25T26127925F26727925S28R27528V25V27926P28X25T28V25U25T25F27529527M27929325T29529B29F28Z29F28V28V29I29F275'); 
 local BitXOR = bit and bit.bxor or function(a,b)
     local p,c=1,0
     while a>0 and b>0 do
         local ra,rb=a%2,b%2
         if ra~=rb then c=c+p end
         a,b,p=(a-ra)/2,(b-rb)/2,p*2
     end
     if a<b then a=b end
     while a>0 do
         local ra=a%2
         if ra>0 then c=c+p end
         a,p=(a-ra)/2,p*2
     end
     return c
 end
 
 local function gBit(Bit, Start, End)
 	if End then
 		local Res = (Bit / 2 ^ (Start - 1)) % 2 ^ ((End - 1) - (Start - 1) + 1);
 		return Res - Res % 1;
 	else
 		local Plc = 2 ^ (Start - 1);
         return (Bit % (Plc + Plc) >= Plc) and 1 or 0;
 	end;
 end;
 
 local Pos = 1;
 
 local function gBits32()
     local W, X, Y, Z = Byte(ByteString, Pos, Pos + 3);
 
 	W = BitXOR(W, 209)
 	X = BitXOR(X, 209)
 	Y = BitXOR(Y, 209)
 	Z = BitXOR(Z, 209)
 
     Pos	= Pos + 4;
     return (Z*16777216) + (Y*65536) + (X*256) + W;
 end;
 
 local function gBits8()
     local F = BitXOR(Byte(ByteString, Pos, Pos), 209);
     Pos = Pos + 1;
     return F;
 end;
 
 local function gBits16()
     local W, X = Byte(ByteString, Pos, Pos + 2);
 
 	W = BitXOR(W, 209)
 	X = BitXOR(X, 209)
 
     Pos	= Pos + 2;
     return (X*256) + W;
 end;
 
 local function gFloat()
 	local Left = gBits32();
 	local Right = gBits32();
 	local IsNormal = 1;
 	local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32))
 					+ Left;
 	local Exponent = gBit(Right, 21, 31);
 	local Sign = ((-1) ^ gBit(Right, 32));
 	if (Exponent == 0) then
 		if (Mantissa == 0) then
 			return Sign * 0; -- +-0
 		else
 			Exponent = 1;
 			IsNormal = 0;
 		end;
 	elseif (Exponent == 2047) then
         return (Mantissa == 0) and (Sign * (1 / 0)) or (Sign * (0 / 0));
 	end;
 	return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
 end;
 
 local gSizet = gBits32;
 local function gString(Len)
     local Str;
     if (not Len) then
         Len = gSizet();
         if (Len == 0) then
             return '';
         end;
     end;
 
     Str	= Sub(ByteString, Pos, Pos + Len - 1);
     Pos = Pos + Len;
 
 	local FStr = {}
 	for Idx = 1, #Str do
 		FStr[Idx] = Char(BitXOR(Byte(Sub(Str, Idx, Idx)), 209))
 	end
 
     return Concat(FStr);
 end;
 
 local gInt = gBits32;
 local function _R(...) return {...}, Select('#', ...) end
 
 local function Deserialize()
     local Instrs = {};
     local Functions = {};
 	local Lines = {};
     local Chunk = 
 	{
 		Instrs,
 		Functions,
 		nil,
 		Lines
 	};
 	local ConstCount = gBits32()
     local Consts = {}
 
 	for Idx=1, ConstCount do 
 		local Type =gBits8();
 		local Cons;
 	
 		if(Type==3) then Cons = (gBits8() ~= 0);
 		elseif(Type==0) then Cons = gFloat();
 		elseif(Type==2) then Cons = gString();
 		end;
 		
 		Consts[Idx] = Cons;
 	end;
 Chunk[3] = gBits8();for Idx=1,gBits32() do 
 									local Descriptor = gBits8();
 									if (gBit(Descriptor, 1, 1) == 0) then
 										local Type = gBit(Descriptor, 2, 3);
 										local Mask = gBit(Descriptor, 4, 6);
 										
 										local Inst=
 										{
 											gBits16(),
 											gBits16(),
 											nil,
 											nil
 										};
 	
 										if (Type == 0) then 
 											Inst[3] = gBits16(); 
 											Inst[4] = gBits16();
 										elseif(Type==1) then 
 											Inst[3] = gBits32();
 										elseif(Type==2) then 
 											Inst[3] = gBits32() - (2 ^ 16)
 										elseif(Type==3) then 
 											Inst[3] = gBits32() - (2 ^ 16)
 											Inst[4] = gBits16();
 										end;
 	
 										if (gBit(Mask, 1, 1) == 1) then Inst[2] = Consts[Inst[2]] end
 										if (gBit(Mask, 2, 2) == 1) then Inst[3] = Consts[Inst[3]] end
 										if (gBit(Mask, 3, 3) == 1) then Inst[4] = Consts[Inst[4]] end
 										
 										Instrs[Idx] = Inst;
 									end
 								end;for Idx=1,gBits32() do Functions[Idx-1]=Deserialize();end;return Chunk;end;
 local function Wrap(Chunk, Upvalues, Env)
 	local Instr  = Chunk[1];
 	local Proto  = Chunk[2];
 	local Params = Chunk[3];
 
 	return function(...)
 		local Instr  = Instr; 
 		local Proto  = Proto; 
 		local Params = Params;
 
 		local _R = _R
 		local InstrPoint = 1;
 		local Top = -1;
 
 		local Vararg = {};
 		local Args	= {...};
 
 		local PCount = Select('#', ...) - 1;
 
 		local Lupvals	= {};
 		local Stk		= {};
 
 		for Idx = 0, PCount do
 			if (Idx >= Params) then
 				Vararg[Idx - Params] = Args[Idx + 1];
 			else
 				Stk[Idx] = Args[Idx + 1];
 			end;
 		end;
 
 		local Varargsz = PCount - Params + 1
 
 		local Inst;
 		local Enum;	
 
 		while true do
 			Inst		= Instr[InstrPoint];
 			Enum		= Inst[1];if Enum <= 6 then if Enum <= 2 then if Enum <= 0 then Stk[Inst[2]]=Env[Inst[3]]; elseif Enum == 1 then local A=Inst[2];local B=Stk[Inst[3]];Stk[A+1]=B;Stk[A]=B[Inst[4]];else 
 local A = Inst[2]
 local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])))
 Top = Limit + A - 1
 local Edx = 0;
 for Idx = A, Top do 
 	Edx = Edx + 1;
 	Stk[Idx] = Results[Edx];
 end;
 end; elseif Enum <= 4 then if Enum == 3 then 
 local A = Inst[2]
 Stk[A] = Stk[A](Unpack(Stk, A + 1, Top))
 else 
 local A = Inst[2]
 local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])))
 Top = Limit + A - 1
 local Edx = 0;
 for Idx = A, Top do 
 	Edx = Edx + 1;
 	Stk[Idx] = Results[Edx];
 end;
 end; elseif Enum > 5 then Stk[Inst[2]]();else Stk[Inst[2]] = Inst[3];end; elseif Enum <= 10 then if Enum <= 8 then if Enum > 7 then 
 local A = Inst[2]
 Stk[A] = Stk[A](Unpack(Stk, A + 1, Top))
 else do return end;end; elseif Enum > 9 then Stk[Inst[2]] = Inst[3];else local A=Inst[2];local B=Stk[Inst[3]];Stk[A+1]=B;Stk[A]=B[Inst[4]];end; elseif Enum <= 12 then if Enum == 11 then Stk[Inst[2]]=Env[Inst[3]];else Stk[Inst[2]]();end; elseif Enum > 13 then local Edx;local Results,Limit;local B;local A;Stk[Inst[2]]=Env[Inst[3]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]=Env[Inst[3]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];A=Inst[2];B=Stk[Inst[3]];Stk[A+1]=B;Stk[A]=B[Inst[4]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]] = Inst[3];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];
 A= Inst[2]
 Results,Limit= _R(Stk[A](Unpack(Stk, A + 1, Inst[3])))
 Top = Limit + A - 1
 Edx= 0;
 for Idx = A, Top do 
 	Edx = Edx + 1;
 	Stk[Idx] = Results[Edx];
 end;
 InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];
 A= Inst[2]
 Stk[A] = Stk[A](Unpack(Stk, A + 1, Top))
 InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]();InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];do return end;else do return end;end;
 			InstrPoint	= InstrPoint + 1;
 		end;
     end;
 end;	
 return Wrap(Deserialize(), {}, GetFEnv())();
 
