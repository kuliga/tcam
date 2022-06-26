#ifndef _TCAM_H_
#define _TCAM_H_

#include <fsl.h>
#include <xil_types.h>

/*
 * [31-16] [15-0]
 * [address][opcode]
 */

#define OPCODE_READ		(0x01U)
#define OPCODE_WRITE	(0x00U)
#define OPCODE_CLEAR 	(0x10U)

#define __tcam_set_entry(addr, key, mask, data, fsl_id)											\
								do {															\
									u32 dummy;													\
									union {														\
										u32 word;												\
										u16 halfword[2];										\
									} _tmp;														\
									_tmp.halfword[1] = addr;									\
									_tmp.halfword[0] = OPCODE_WRITE;							\
									const register u32 control_reg = _tmp.word;					\
									const register u32 key_reg = key;							\
									const register u32 mask_reg = mask;							\
									const register u32 data_reg = data;							\
									putfslx(control_reg, fsl_id, FSL_NONBLOCKING_ATOMIC);		\
									putfslx(key_reg, fsl_id, FSL_NONBLOCKING_ATOMIC);			\
									putfslx(mask_reg, fsl_id, FSL_NONBLOCKING_ATOMIC);			\
									putfslx(data_reg, fsl_id, FSL_NONBLOCKING_CONTROL_ATOMIC);	\
									getfslx(dummy, fsl_id, FSL_ATOMIC);							\
								} while (0)

#define __tcam_clear_entry(key, fsl_id)															\
								do {															\
									u32 dummy;													\
									const register u32 control_reg = OPCODE_CLEAR;				\
									const register u32 key_reg = key;							\
									putfslx(control_reg, fsl_id, FSL_NONBLOCKING_ATOMIC);		\
									putfslx(key_reg, fsl_id, FSL_NONBLOCKING_CONTROL_ATOMIC);	\
									getfslx(dummy, fsl_id, FSL_NONBLOCKING_ATOMIC);				\
								} while (0)

#define __tcam_get_entry(key, fsl_id)															\
								({register u32 data;											\
								do {															\
									const register u32 control_reg = OPCODE_READ;				\
									const register u32 key_reg = key;							\
									putfslx(control_reg, fsl_id, FSL_NONBLOCKING_ATOMIC);		\
									putfslx(key_reg, fsl_id, FSL_NONBLOCKING_CONTROL_ATOMIC);	\
									getfslx(data, fsl_id, FSL_ATOMIC);							\
								} while (0);													\
								data;})

#endif
