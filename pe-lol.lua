--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_12703 = 0;
			while true do
				if (FlatIdent_12703 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_2BD95 = 0;
				local b;
				while true do
					if (FlatIdent_2BD95 == 1) then
						return b;
					end
					if (FlatIdent_2BD95 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_2BD95 = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_60EA1 = 0;
			local Res;
			while true do
				if (FlatIdent_60EA1 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_31A5A = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_31A5A == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (FlatIdent_31A5A == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_31A5A = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_31905 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_31905 == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						FlatIdent_31905 = 2;
					end
					if (0 == FlatIdent_31905) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_31905 = 1;
					end
					if (FlatIdent_31905 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_31905 = 3;
					end
					if (FlatIdent_31905 == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 33) then
					if (Enum <= 16) then
						if (Enum <= 7) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum == 0) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 2) then
									local B;
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								else
									local A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum == 6) then
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 11) then
							if (Enum <= 9) then
								if (Enum > 8) then
									local A;
									A = Inst[2];
									Stk[A] = Stk[A]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Env[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum == 10) then
								local A;
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 13) then
							if (Enum == 12) then
								local K;
								local B;
								local A;
								A = Inst[2];
								Stk[A] = Stk[A]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Upvalues[Inst[3]] = Stk[Inst[2]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Env[Inst[3]] = Stk[Inst[2]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local FlatIdent_49AED = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_49AED == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_49AED = 2;
									end
									if (FlatIdent_49AED == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_49AED = 7;
									end
									if (FlatIdent_49AED == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_49AED = 1;
									end
									if (FlatIdent_49AED == 10) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_49AED == 9) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_49AED = 10;
									end
									if (FlatIdent_49AED == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_49AED = 8;
									end
									if (FlatIdent_49AED == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_49AED = 6;
									end
									if (FlatIdent_49AED == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_49AED = 3;
									end
									if (FlatIdent_49AED == 3) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_49AED = 4;
									end
									if (FlatIdent_49AED == 4) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_49AED = 5;
									end
									if (FlatIdent_49AED == 8) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_49AED = 9;
									end
								end
							end
						elseif (Enum <= 14) then
							local A = Inst[2];
							Stk[A] = Stk[A]();
						elseif (Enum > 15) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
						end
					elseif (Enum <= 24) then
						if (Enum <= 20) then
							if (Enum <= 18) then
								if (Enum > 17) then
									local FlatIdent_6B983 = 0;
									local NewProto;
									local NewUvals;
									local Indexes;
									while true do
										if (FlatIdent_6B983 == 2) then
											for Idx = 1, Inst[4] do
												local FlatIdent_D79D = 0;
												local Mvm;
												while true do
													if (0 == FlatIdent_D79D) then
														VIP = VIP + 1;
														Mvm = Instr[VIP];
														FlatIdent_D79D = 1;
													end
													if (FlatIdent_D79D == 1) then
														if (Mvm[1] == 53) then
															Indexes[Idx - 1] = {Stk,Mvm[3]};
														else
															Indexes[Idx - 1] = {Upvalues,Mvm[3]};
														end
														Lupvals[#Lupvals + 1] = Indexes;
														break;
													end
												end
											end
											Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
											break;
										end
										if (FlatIdent_6B983 == 1) then
											Indexes = {};
											NewUvals = Setmetatable({}, {__index=function(_, Key)
												local FlatIdent_2D88C = 0;
												local Val;
												while true do
													if (FlatIdent_2D88C == 0) then
														Val = Indexes[Key];
														return Val[1][Val[2]];
													end
												end
											end,__newindex=function(_, Key, Value)
												local Val = Indexes[Key];
												Val[1][Val[2]] = Value;
											end});
											FlatIdent_6B983 = 2;
										end
										if (FlatIdent_6B983 == 0) then
											NewProto = Proto[Inst[3]];
											NewUvals = nil;
											FlatIdent_6B983 = 1;
										end
									end
								else
									local FlatIdent_28F1 = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (2 == FlatIdent_28F1) then
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
										if (0 == FlatIdent_28F1) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_28F1 = 1;
										end
										if (1 == FlatIdent_28F1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_28F1 = 2;
										end
									end
								end
							elseif (Enum > 19) then
								local FlatIdent_49280 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_49280 == 6) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_49280 == 2) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_49280 = 3;
									end
									if (FlatIdent_49280 == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_49280 = 2;
									end
									if (FlatIdent_49280 == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_49280 = 6;
									end
									if (FlatIdent_49280 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_49280 = 1;
									end
									if (FlatIdent_49280 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_49280 = 5;
									end
									if (FlatIdent_49280 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_49280 = 4;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							end
						elseif (Enum <= 22) then
							if (Enum == 21) then
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 23) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Top do
								Insert(T, Stk[Idx]);
							end
						else
							local FlatIdent_61800 = 0;
							local A;
							while true do
								if (FlatIdent_61800 == 0) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						end
					elseif (Enum <= 28) then
						if (Enum <= 26) then
							if (Enum > 25) then
								local A;
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum == 27) then
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							for Idx = Inst[2], Inst[3] do
								Stk[Idx] = nil;
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local FlatIdent_90A41 = 0;
							local A;
							while true do
								if (FlatIdent_90A41 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
							end
						end
					elseif (Enum <= 30) then
						if (Enum > 29) then
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 31) then
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
					elseif (Enum == 32) then
						local A = Inst[2];
						local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
						local Edx = 0;
						for Idx = A, Inst[4] do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
					else
						local A = Inst[2];
						local C = Inst[4];
						local CB = A + 2;
						local Result = {Stk[A](Stk[A + 1], Stk[CB])};
						for Idx = 1, C do
							Stk[CB + Idx] = Result[Idx];
						end
						local R = Result[1];
						if R then
							Stk[CB] = R;
							VIP = Inst[3];
						else
							VIP = VIP + 1;
						end
					end
				elseif (Enum <= 50) then
					if (Enum <= 41) then
						if (Enum <= 37) then
							if (Enum <= 35) then
								if (Enum == 34) then
									Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								else
									local FlatIdent_28014 = 0;
									local A;
									while true do
										if (FlatIdent_28014 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28014 = 7;
										end
										if (FlatIdent_28014 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28014 = 1;
										end
										if (FlatIdent_28014 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											FlatIdent_28014 = 2;
										end
										if (FlatIdent_28014 == 7) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28014 = 8;
										end
										if (FlatIdent_28014 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_28014 = 3;
										end
										if (FlatIdent_28014 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28014 = 4;
										end
										if (FlatIdent_28014 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_28014 = 6;
										end
										if (FlatIdent_28014 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_28014 = 5;
										end
										if (FlatIdent_28014 == 8) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
									end
								end
							elseif (Enum == 36) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							else
								local FlatIdent_7E707 = 0;
								local A;
								while true do
									if (FlatIdent_7E707 == 0) then
										A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Top));
										end
										break;
									end
								end
							end
						elseif (Enum <= 39) then
							if (Enum == 38) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								Stk[Inst[2]] = Upvalues[Inst[3]];
							end
						elseif (Enum > 40) then
							if (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local Edx;
							local Results, Limit;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								local FlatIdent_32BB2 = 0;
								while true do
									if (FlatIdent_32BB2 == 0) then
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
										break;
									end
								end
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							do
								return Stk[A](Unpack(Stk, A + 1, Top));
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							do
								return Unpack(Stk, A, Top);
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 45) then
						if (Enum <= 43) then
							if (Enum == 42) then
								Stk[Inst[2]] = Env[Inst[3]];
							else
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							end
						elseif (Enum == 44) then
							local FlatIdent_21297 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_21297 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_21297 = 1;
								end
								if (FlatIdent_21297 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_21297 = 3;
								end
								if (FlatIdent_21297 == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_21297 = 7;
								end
								if (FlatIdent_21297 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_21297 = 2;
								end
								if (FlatIdent_21297 == 7) then
									Stk[A] = B[Inst[4]];
									break;
								end
								if (FlatIdent_21297 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_21297 = 5;
								end
								if (FlatIdent_21297 == 3) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_21297 = 4;
								end
								if (FlatIdent_21297 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_21297 = 6;
								end
							end
						else
							local FlatIdent_82923 = 0;
							local A;
							while true do
								if (FlatIdent_82923 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_82923 == 2) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_82923 = 3;
								end
								if (FlatIdent_82923 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Env[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									FlatIdent_82923 = 5;
								end
								if (3 == FlatIdent_82923) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									FlatIdent_82923 = 4;
								end
								if (FlatIdent_82923 == 1) then
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_82923 = 2;
								end
								if (FlatIdent_82923 == 0) then
									A = nil;
									A = Inst[2];
									Stk[A] = Stk[A]();
									VIP = VIP + 1;
									FlatIdent_82923 = 1;
								end
							end
						end
					elseif (Enum <= 47) then
						if (Enum == 46) then
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local FlatIdent_71EE8 = 0;
									local Upv;
									local NStk;
									local DIP;
									while true do
										if (1 == FlatIdent_71EE8) then
											DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												Cls[DIP] = NStk[DIP];
												Upv[1] = Cls;
											end
											break;
										end
										if (FlatIdent_71EE8 == 0) then
											Upv = List[Idz];
											NStk = Upv[1];
											FlatIdent_71EE8 = 1;
										end
									end
								end
							end
						else
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						end
					elseif (Enum <= 48) then
						Stk[Inst[2]]();
					elseif (Enum == 49) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					else
						local A = Inst[2];
						local B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					end
				elseif (Enum <= 59) then
					if (Enum <= 54) then
						if (Enum <= 52) then
							if (Enum == 51) then
								local FlatIdent_4E551 = 0;
								while true do
									if (FlatIdent_4E551 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4E551 = 3;
									end
									if (FlatIdent_4E551 == 0) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_4E551 = 1;
									end
									if (FlatIdent_4E551 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										FlatIdent_4E551 = 2;
									end
									if (3 == FlatIdent_4E551) then
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
								end
							else
								do
									return;
								end
							end
						elseif (Enum == 53) then
							Stk[Inst[2]] = Stk[Inst[3]];
						elseif (Stk[Inst[2]] ~= Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 56) then
						if (Enum > 55) then
							local A = Inst[2];
							Top = (A + Varargsz) - 1;
							for Idx = A, Top do
								local VA = Vararg[Idx - A];
								Stk[Idx] = VA;
							end
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 57) then
						do
							return Stk[Inst[2]];
						end
					elseif (Enum == 58) then
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					else
						local FlatIdent_55D83 = 0;
						local Results;
						local Edx;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_55D83 == 7) then
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_56F59 = 0;
									while true do
										if (FlatIdent_56F59 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								FlatIdent_55D83 = 8;
							end
							if (FlatIdent_55D83 == 9) then
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (3 == FlatIdent_55D83) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_55D83 = 4;
							end
							if (FlatIdent_55D83 == 1) then
								A = nil;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 2;
							end
							if (FlatIdent_55D83 == 0) then
								Results = nil;
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								FlatIdent_55D83 = 1;
							end
							if (8 == FlatIdent_55D83) then
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								FlatIdent_55D83 = 9;
							end
							if (4 == FlatIdent_55D83) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_55D83 = 5;
							end
							if (FlatIdent_55D83 == 2) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_55D83 = 3;
							end
							if (FlatIdent_55D83 == 5) then
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_55D83 = 6;
							end
							if (FlatIdent_55D83 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								FlatIdent_55D83 = 7;
							end
						end
					end
				elseif (Enum <= 63) then
					if (Enum <= 61) then
						if (Enum > 60) then
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						else
							Upvalues[Inst[3]] = Stk[Inst[2]];
						end
					elseif (Enum > 62) then
						Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
					else
						local FlatIdent_3121 = 0;
						local B;
						local K;
						while true do
							if (FlatIdent_3121 == 1) then
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								break;
							end
							if (FlatIdent_3121 == 0) then
								B = Inst[3];
								K = Stk[B];
								FlatIdent_3121 = 1;
							end
						end
					end
				elseif (Enum <= 65) then
					if (Enum > 64) then
						if (Stk[Inst[2]] < Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						local FlatIdent_51C44 = 0;
						local A;
						while true do
							if (FlatIdent_51C44 == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								break;
							end
						end
					end
				elseif (Enum <= 66) then
					Env[Inst[3]] = Stk[Inst[2]];
				elseif (Enum == 67) then
					local FlatIdent_92514 = 0;
					local A;
					while true do
						if (FlatIdent_92514 == 0) then
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							break;
						end
					end
				else
					local A = Inst[2];
					do
						return Unpack(Stk, A, A + Inst[3]);
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!563O0003073O0067657467656E76030A3O00737472616E67656C6F6C030A3O00537472616E67656C6F6C03073O00456E61626C656403133O0050726564696374696F6E2053652O74696E6773030A3O0050726564696374696F6E030D3O004E6F74696669636174696F6E7303073O0041696D5061727403063O0043616D657261030E3O00536D2O6F746843616D53702O6564030E3O005368616B65496E74656E7369747903083O00496E7374616E63652O033O006E657703043O00542O6F6C030E3O00526571756972657348616E646C65010003043O004E616D6503053O005B5245565D03043O0067616D65030A3O004765745365727669636503093O00576F726B7370616365030D3O0043752O72656E7443616D65726103073O00506C6179657273030B3O004C6F63616C506C6179657203083O004765744D6F75736503043O005061727403083O00416E63686F7265642O01030A3O0043616E436F2O6C69646503053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742025O00E06F40028O0003083O004D6174657269616C03043O00456E756D03043O004E656F6E03043O0053697A6503073O00566563746F723302C3F5285C8FC2ED3F03053O00536861706503083O00506172745479706503053O00426C6F636B030C3O005472616E73706172656E6379026O00F03F03113O0046696E64436C6F73657374506C61796572030D3O00536D2O6F746843616D4C6F636B03093O0041637469766174656403073O00436F2O6E656374030A3O0052756E5365727669636503073O005374652O706564030F3O006765747261776D6574617461626C65030A3O002O5F6E616D6563612O6C030B3O00736574726561646F6E6C79030B3O006E65772O636C6F7375726503063O00506172656E7403083O004261636B7061636B030E3O00436861726163746572412O646564030C3O0057616974466F724368696C6403093O00506C6179657247756903093O005363722O656E477569030C3O00436F72706F726174696F6E73030C3O0052657365744F6E537061776E030A3O005465787442752O746F6E03083O00496D70657269616C03103O004261636B67726F756E64436F6C6F723303163O004261636B67726F756E645472616E73706172656E6379026O00E03F030F3O00426F7264657253697A65506978656C03083O00506F736974696F6E03053O005544696D32026O005EC0026O002440026O005940026O00324003043O00466F6E74030A3O00536F7572636553616E7303043O0054657874030A3O005269676874636C69636B030A3O0054657874436F6C6F723303083O005465787453697A6503083O005549436F726E657203113O004D6F75736542752O746F6E31436C69636B030A3O006C6F6164737472696E6703073O00482O747047657403633O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F556E6B6E6F776E6C6F6466632F69646B2F6D61696E2F5A6570687972253230253743253230556E6976657273616C2532304669676874696E6725323047616D657300C53O00121B3O00018O0001000200206O000200202O00013O000300202O00010001000400202O00023O000500202O00020002000600202O00033O000300202O00030003000700202O00043O000500202O00040004000800202O00053O000300202O00050005000900202O00050005000A00202O00063O000300202O00060006000900202O00060006000B00122O0007000C3O00202O00070007000D00122O0008000E6O00070002000200302O0007000F001000302O00070011001200122O000800133O00202O00080008001400122O000A00156O0008000A000200202O00080008001600122O000900133O00202O00090009001700202O00090009001800202O0009000900194O0009000200024O000A000A3O00122O000B000C3O00202O000B000B000D00122O000C001A3O00122O000D00133O00202O000D000D00154O000B000D000200302O000B001B001C00302O000B001D001000122O000C001F3O00202O000C000C002000122O000D00213O00122O000E00223O00122O000F00226O000C000F000200102O000B001E000C00122O000C00243O00202O000C000C002300202O000C000C002500102O000B0023000C00122O000C00273O00202O000C000C000D00122O000D00283O00122O000E00283O00122O000F00286O000C000F000200102O000B0026000C00122O000C00243O00202O000C000C002A00202O000C000C002B00102O000B0029000C00302O000B002C002D000612000C3O000100022O00353O00084O00353O00093O001242000C002E3O000612000C0001000100032O00353O00064O00353O00084O00353O00053O001242000C002F3O002031000C00070030002032000C000C0031000612000E0002000100032O00353O00014O00353O00034O00353O000A4O002C000C000E000100122O000C00133O00202O000C000C001400122O000E00326O000C000E000200202O000C000C003300202O000C000C0031000612000E0003000100032O00353O00014O00353O00044O00353O000B4O000A000C000E000100122O000C00343O00122O000D00136O000C0002000200202O000D000C003500122O000E00366O000F000C6O00108O000E0010000100122O000E00373O000612000F0004000100042O00353O000D4O00353O00014O00353O00044O00353O00024O001A000E0002000200102O000C0035000E00122O000E00133O00202O000E000E001700202O000E000E001800202O000E000E003900102O00070038000E00122O000E00133O00202O000E000E001700202O000E000E0018002031000E000E003A002032000E000E003100061200100005000100012O00353O00074O0002000E0010000100122O000E00133O00202O000E000E001700202O000E000E001800202O000F000E003B00122O0011003C6O000F0011000200122O0010000C3O00202O00100010000D00122O0011003D6O00100002000200302O00100011003E00302O0010003F001000102O00100038000F00122O0011000C3O00202O00110011000D00122O001200406O00110002000200302O00110011004100102O00110038001000122O0012001F3O00202O00120012002000122O001300223O00122O001400223O00122O001500226O00120015000200102O00110042001200302O00110043004400302O00110045002200122O001200473O00202O00120012000D00122O0013002D3O00122O001400483O00122O001500223O00122O001600496O00120016000200102O00110046001200122O001200473O00202O00120012000D00122O001300223O00122O0014004A3O00122O001500223O00122O0016004B6O00120016000200102O00110026001200122O001200243O00202O00120012004C00202O00120012004D00102O0011004C001200302O0011004E004F00122O0012001F3O00202O00120012002000122O001300213O00122O001400213O00122O001500216O00120015000200102O00110050001200302O00110051004B00122O0012000C3O00202O00120012000D00122O001300526O00120002000200102O00120038001100022B001300063O00203D00140011005300202O0014001400314O001600136O00140016000100122O001400543O00122O001500133O00202O00150015005500122O001700566O001500176O00143O00022O00300014000100012O002E8O00343O00013O00073O00163O0003043O006D61746803043O006875676503053O00706169727303043O0067616D6503073O00506C6179657273030A3O00476574506C6179657273030B3O004C6F63616C506C6179657203093O00436861726163746572030E3O0046696E6446697273744368696C6403083O0048756D616E6F696403063O004865616C7468028O0003103O0048756D616E6F6964522O6F7450617274026O00F03F03143O00576F726C64546F56696577706F7274506F696E74030B3O005072696D6172795061727403083O00506F736974696F6E03073O00566563746F72322O033O006E657703013O005803013O005903093O006D61676E6974756465004D3O00123B000100013O00202O00010001000200122O000200033O00122O000300043O00202O00030003000500202O0003000300064O000300046O00023O000400044O0049000100122A000700043O002031000700070005002031000700070007002O06000600490001000700041D3O004900010020310007000600080006160007004900013O00041D3O0049000100203100070006000800203200070007000900120B0009000A4O001C0007000900020006160007004900013O00041D3O0049000100203100070006000800203100070007000A00203100070007000B002636000700490001000C00041D3O0049000100203100070006000800203200070007000900120B0009000D4O001C0007000900020006160007004900013O00041D3O0049000100120B0007000C4O0024000800093O000E29000E00300001000700041D3O00300001000641000900490001000100041D3O0049000100120B000A000C3O002601000A00290001000C00041D3O002900012O00353O00064O0035000100093O00041D3O0049000100041D3O0029000100041D3O00490001002601000700240001000C00041D3O002400012O0027000A5O002019000A000A000F00202O000C0006000800202O000C000C001000202O000C000C00114O000A000C00024O0008000A3O00122O000A00123O00202O000A000A001300202O000B0008001400202O000C000800154O000A000C000200122O000B00123O00202O000B000B00134O000C00013O00202O000C000C00144O000D00013O00202O000D000D00154O000B000D00024O000A000A000B00202O0009000A001600122O0007000E3O00044O00240001000621000200090001000200041D3O000900012O00393O00024O00343O00017O000A3O00028O00026O00F03F03073O00566563746F72332O033O006E657703043O006D61746803063O0072616E646F6D027O004003063O00434672616D6503043O004C65727003083O00506F736974696F6E013C3O00120B000100014O0024000200043O002601000100270001000200041D3O0027000100122A000500033O00200D00050005000400122O000600053O00202O0006000600064O0006000100024O00078O00060006000700202O0006000600074O00078O00060006000700122O000700053O00202O0007000700064O0007000100024O00088O00070007000800202O0007000700074O00088O00070007000800122O000800053O00202O0008000800064O0008000100024O00098O00080008000900202O0008000800074O00098O0008000800094O0005000800024O000400056O000500013O00202O0006000200094O0008000300044O000900026O00060009000200102O00050008000600044O003B0001002601000100020001000100041D3O0002000100120B000500013O0026010005002E0001000200041D3O002E000100120B000100023O00041D3O000200010026010005002A0001000100041D3O002A00012O0027000600013O00202O00020006000800122O000600083O00202O00060006000400202O00070002000A4O00088O0006000800024O000300063O00122O000500023O00044O002A000100041D3O000200012O00343O00017O000E3O00028O0003113O0046696E64436C6F73657374506C61796572030C3O00546172676574506C6179657203083O00746F737472696E67026O00F03F03043O0067616D65030A3O005374617274657247756903073O00536574436F726503103O0053656E644E6F74696669636174696F6E03053O005469746C65030B3O00737472616E67652E6C6F6C03043O005465787403213O00756E6C6F636B6564206F7220636F756C646E742066696E64206120706572736F6E035O005A4O00277O0006163O003100013O00041D3O0031000100120B3O00014O0024000100013O0026013O00050001000100041D3O0005000100120B000100013O002601000100080001000100041D3O000800012O000800026O003C00026O0027000200013O0006160002005900013O00041D3O0059000100120B000200014O0024000300033O002601000200110001000100041D3O0011000100120B000300013O0026010003001E0001000100041D3O001E000100122A000400024O002D0004000100024O000400023O00122O000400046O000500026O00040002000200122O000400033O00122O000300053O002601000300140001000500041D3O0014000100122A000400063O00201400040004000700202O00040004000800122O000600096O00073O000200302O0007000A000B00302O0007000C000D4O00040007000100044O0059000100041D3O0014000100041D3O0059000100041D3O0011000100041D3O0059000100041D3O0008000100041D3O0059000100041D3O0005000100041D3O0059000100120B3O00013O0026013O003C0001000100041D3O003C000100122A000100024O002D0001000100024O000100023O00122O000100046O000200026O00010002000200122O000100033O00124O00053O0026013O00320001000500041D3O003200012O0008000100014O003C00016O0027000100013O0006160001005900013O00041D3O0059000100122A000100024O000C0001000100024O000100023O00122O000100046O000200026O00010002000200122O000100033O00122O000100063O00202O00010001000700202O00010001000800122O000300096O00043O000200302O0004000A000B00122O0005000E3O00122O000600043O00122O000700036O0006000200024O00050005000600102O0004000C00054O00010004000100044O0059000100041D3O003200012O00343O00017O000C3O0003043O0067616D6503073O00506C6179657273030C3O00546172676574506C6179657203093O00436861726163746572030E3O0046696E6446697273744368696C64028O00026O00F03F03083O00506F736974696F6E030D3O00536D2O6F746843616D4C6F636B03063O00434672616D652O033O006E6577024O008087C3C000434O00277O0006163O003A00013O00041D3O003A000100122A3O00013O0020315O000200122A000100034O00135O00010006163O003100013O00041D3O0031000100122A3O00013O0020335O000200122O000100039O00000100206O000400064O003100013O00041D3O0031000100122A3O00013O0020045O000200122O000100039O00000100206O000400206O00054O000200018O0002000200064O003100013O00041D3O0031000100120B3O00064O0024000100013O0026013O00210001000700041D3O002100012O0027000200023O002O1000020008000100041D3O004200010026013O001C0001000600041D3O001C000100122A000200013O00202300020002000200122O000300036O00020002000300202O0002000200044O000300016O00020002000300202O00010002000800122O000200096O000300016O00020002000100124O00073O00044O001C000100041D3O004200012O00273O00023O00121E0001000A3O00202O00010001000B00122O000200063O00122O0003000C3O00122O000400066O00010004000200104O000A000100041D3O004200012O00273O00023O00121E0001000A3O00202O00010001000B00122O000200063O00122O0003000C3O00122O000400066O00010004000200104O000A00012O00343O00017O000E3O00028O00026O00F03F03113O006765746E616D6563612O6C6D6574686F64030A3O0046697265536572766572027O0040030E3O005570646174654D6F757365506F73026O00084003043O0067616D6503073O00506C6179657273030C3O00546172676574506C6179657203093O0043686172616374657203083O00506F736974696F6E03083O0056656C6F6369747903063O00756E7061636B00463O00120B000100014O0024000200023O00120B000300013O000E29000100030001000300041D3O00030001000E290002000B0001000100041D3O000B00012O002700046O003800056O002500046O000300045O002601000100020001000100041D3O0002000100120B000400013O002601000400120001000200041D3O0012000100120B000100023O00041D3O000200010026010004000E0001000100041D3O000E00012O003700056O003800066O001700053O00012O0035000200054O0027000500013O0006160005004000013O00041D3O0040000100122A000500034O000E000500010002002601000500400001000400041D3O00400001002031000500020005002601000500400001000600041D3O0040000100120B000500013O000E29000100230001000500041D3O0023000100122A000600083O00202800060006000900122O0007000A6O00060006000700202O00060006000B4O000700026O00060006000700202O00060006000C00122O000700083O00202O00070007000900122O0008000A6O00070007000800202O00070007000B4O000800026O00070007000800202O00070007000D4O000800036O0007000700084O00060006000700102O0002000700064O00065O00122O0007000E6O000800026O000700086O00068O00065O00044O0023000100120B000400023O00041D3O000E000100041D3O0002000100041D3O0003000100041D3O000200012O00343O00017O00053O0003063O00506172656E7403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203083O004261636B7061636B00074O002F7O00122O000100023O00202O00010001000300202O00010001000400202O00010001000500104O000100016O00017O00063O00028O0003043O0067616D65030A3O004765745365727669636503133O005669727475616C496E7075744D616E61676572030C3O0053656E644B65794576656E7403083O0042752O746F6E4C3200123O00120B3O00014O0024000100013O0026013O00020001000100041D3O0002000100122A000200023O00201500020002000300122O000400046O0002000400024O000100023O00202O0002000100054O000400013O00122O000500066O00065O00122O000700026O00020007000100044O0011000100041D3O000200012O00343O00017O00", GetFEnv(), ...);
