#include "instructions.h"

instruction rtoin(RType r) {
	instruction instruc = 0;
	instruc |= r.opcode << 12;
	instruc |= r.reg1 << 8;
	instruc |= r.reg2 << 4;
	instruc |= r.addressMode << 2;
	instruc |= r.padding;
	return instruc;
}

instruction itoin(IType i) {
	instruction instruc = 0;
	instruc |= i.opcode << 12;
	instruc |= i.reg << 8;
	instruc |= i.immediate;
	return instruc;
}

instruction jtoin(JType j) {
	instruction instruc = 0;
	instruc |= j.opcode << 12;
	instruc |= j.immediate;
	return instruc;
}
