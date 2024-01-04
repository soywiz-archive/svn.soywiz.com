/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psptypes.h - Commonly used typedefs.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psptypes.h 2312 2007-09-09 15:02:23Z chip $
 */

/* Note: Some of the structures, types, and definitions in this file were
   extrapolated from symbolic debugging information found in the Japanese
   version of Puzzle Bobble. */
   
module pspsdk.psptypes;

/* Legacy ps2dev types. */
alias ubyte			u8;
alias ushort		u16;

alias uint			u32;
alias ulong			u64;

alias byte			s8;
alias short			s16;

alias int			s32;
alias long			s64;

/+ um, i'll just leave this alone
#ifndef PSP_LEGACY_VOLATILE_TYPES_DEFINED
#define PSP_LEGACY_VOLATILE_TYPES_DEFINED
typedef	volatile uint8_t		vu8;
typedef volatile uint16_t		vu16;

typedef volatile uint32_t		vu32;
typedef volatile uint64_t		vu64;

typedef volatile int8_t			vs8;
typedef volatile int16_t		vs16;

typedef volatile int32_t		vs32;
typedef volatile int64_t		vs64;
#endif
+/

/* MIPS-like accessor macros. */
/+ unsure about this stuff here:
static __inline__ u8  _lb(u32 addr) { return *(vu8 *)addr; }
static __inline__ u16 _lh(u32 addr) { return *(vu16 *)addr; }
static __inline__ u32 _lw(u32 addr) { return *(vu32 *)addr; }
static __inline__ u64 _ld(u32 addr) { return *(vu64 *)addr; }

static __inline__ void _sb(u8 val, u32 addr) { *(vu8 *)addr = val; }
static __inline__ void _sh(u16 val, u32 addr) { *(vu16 *)addr = val; }
static __inline__ void _sw(u32 val, u32 addr) { *(vu32 *)addr = val; }
static __inline__ void _sd(u64 val, u32 addr) { *(vu64 *)addr = val; }
+/

/* SCE types. */
alias ubyte 	SceUChar8;
alias ushort	SceUShort16;
alias uint 		SceUInt32;
alias ulong 	SceUInt64;
alias ulong 	SceULong64;
/*typedef unsigned int SceULong128 __attribute__((mode(TI)));*/

alias byte 	SceChar8;
alias short	SceShort16;
alias int	SceInt32;
alias long	SceInt64;
alias long	SceLong64;
/*typedef int SceLong128 __attribute__((mode(TI)));*/

alias float SceFloat;
alias float SceFloat32;

alias wchar SceWChar16;
alias dchar SceWChar32;

typedef int SceBool;

alias void SceVoid;
alias void* ScePVoid;


/* PSP types. */

/* Rectangles. */
struct ScePspSRect {
	short	x;
	short	y;
	short	w;
	short	h;
};

struct ScePspIRect {
	int 	x;
	int 	y;
	int 	w;
	int 	h;
};

struct ScePspL64Rect {
	SceLong64 	x;
	SceLong64 	y;
	SceLong64 	w;
	SceLong64 	h;
};

struct ScePspFRect {
	float 	x;
	float 	y;
	float 	w;
	float 	h;
};

/* 2D vectors. */
struct ScePspSVector2 {
	short x;
	short y;
};

struct ScePspIVector2 {
	int x;
	int y;
};

struct ScePspL64Vector2 {
	SceLong64 x;
	SceLong64 y;
};

struct ScePspFVector2 {
	float x;
	float y;
};

union ScePspVector2 {
	ScePspFVector2 	fv;
	ScePspIVector2 	iv;
	float 			f[2];
	int 			i[2];
};

/* 3D vectors. */
struct ScePspSVector3 {
	short	x;
	short 	y;
	short 	z;
};

struct ScePspIVector3 {
	int 	x;
	int 	y;
	int 	z;
};

struct ScePspL64Vector3 {
	SceLong64 	x;
	SceLong64 	y;
	SceLong64 	z;
};

struct ScePspFVector3 {
	float 	x;
	float 	y;
	float 	z;
};

union ScePspVector3 {
	ScePspFVector3 	fv;
	ScePspIVector3 	iv;
	float 			f[3];
	int 			i[3];
};

/* 4D vectors. */
struct ScePspSVector4 {
	short	x;
	short 	y;
	short 	z;
	short 	w;
};

struct ScePspIVector4 {
	int 	x;
	int 	y;
	int 	z;
	int 	w;
};

struct ScePspL64Vector4 {
	SceLong64 	x;
	SceLong64 	y;
	SceLong64 	z;
	SceLong64 	w;
};

align(16) struct ScePspFVector4 {
	float 	x;
	float 	y;
	float 	z;
	float 	w;
};

struct ScePspFVector4Unaligned {
	float 	x;
	float 	y;
	float 	z;
	float 	w;
};

align(16) union ScePspVector4 {
	ScePspFVector4 	fv;
	ScePspIVector4 	iv;
/*	SceULong128 	qw;*/	/* Missing compiler support. */
	float 			f[4];
	int 			i[4];
};

/* 2D matrix types. */
struct ScePspIMatrix2 {
	ScePspIVector2 	x;
	ScePspIVector2 	y;
};

struct ScePspFMatrix2 {
	ScePspFVector2 	x;
	ScePspFVector2 	y;
};

union ScePspMatrix2 {
	ScePspFMatrix2 	fm;
	ScePspIMatrix2 	im;
	ScePspFVector2 	fv[2];
	ScePspIVector2 	iv[2];
	ScePspVector2 	v[2];
/*	SceULong128 	qw[2];*/	/* Missing compiler support. */
	float 			f[2][2];
	int 			i[2][2];
};

/* 3D matrix types. */
struct ScePspIMatrix3 {
	ScePspIVector3 	x;
	ScePspIVector3 	y;
	ScePspIVector3 	z;
};

struct ScePspFMatrix3 {
	ScePspFVector3 	x;
	ScePspFVector3 	y;
	ScePspFVector3 	z;
};

union ScePspMatrix3 {
	ScePspFMatrix3 	fm;
	ScePspIMatrix3 	im;
	ScePspFVector3 	fv[3];
	ScePspIVector3 	iv[3];
	ScePspVector3 	v[3];
/*	SceULong128 	qw[3];*/	/* Missing compiler support. */
	float 			f[3][3];
	int 			i[3][3];
};

/* 4D matrix types. */
align(16) struct ScePspIMatrix4 {
	ScePspIVector4 	x;
	ScePspIVector4 	y;
	ScePspIVector4 	z;
	ScePspIVector4 	w;
};

struct ScePspIMatrix4Unaligned {
	ScePspIVector4 	x;
	ScePspIVector4 	y;
	ScePspIVector4 	z;
	ScePspIVector4 	w;
};

align(16) struct ScePspFMatrix4 {
	ScePspFVector4 	x;
	ScePspFVector4 	y;
	ScePspFVector4 	z;
	ScePspFVector4 	w;
};

struct ScePspFMatrix4Unaligned {
	ScePspFVector4 	x;
	ScePspFVector4 	y;
	ScePspFVector4 	z;
	ScePspFVector4 	w;
};

union ScePspMatrix4 {
	ScePspFMatrix4 	fm;
	ScePspIMatrix4 	im;
	ScePspFVector4 	fv[4];
	ScePspIVector4 	iv[4];
	ScePspVector4 	v[4];
/*	SceULong128 	qw[4];*/	/* Missing compiler support. */
	float 			f[4][4];
	int 			i[4][4];
};

/* Quaternions. */
align(16) struct ScePspFQuaternion {
	float 	x;
	float 	y;
	float 	z;
	float 	w;
};

struct ScePspFQuaternionUnaligned {
	float 	x;
	float 	y;
	float 	z;
	float 	w;
};

/* Colors and pixel formats. */
align(16) struct ScePspFColor {
	float 	r;
	float 	g;
	float 	b;
	float 	a;
};

struct ScePspFColorUnaligned {
	float 	r;
	float 	g;
	float 	b;
	float 	a;
};

alias uint ScePspRGBA8888;
alias ushort ScePspRGBA4444;
alias ushort ScePspRGBA5551;
alias ushort ScePspRGB565;

/* Unions for converting between types. */
union ScePspUnion32 {
	uint 	ui;
	int		i;
	ushort 	us[2];
	short	s[2];
	ubyte 	uc[4];
	byte	c[4];
	float	f;
	ScePspRGBA8888 	rgba8888;
	ScePspRGBA4444 	rgba4444[2];
	ScePspRGBA5551 	rgba5551[2];
	ScePspRGB565 	rgb565[2];
};

union ScePspUnion64 {
	SceULong64 		ul;
	SceLong64 		l;
	uint	ui[2];
	int		i[2];
	ushort 	us[4];
	short	s[4];
	ubyte 	uc[8];
	byte	c[8];
	float	f[2];
	ScePspSRect 	sr;
	ScePspSVector4 	sv;
	ScePspRGBA8888 	rgba8888[2];
	ScePspRGBA4444 	rgba4444[4];
	ScePspRGBA5551 	rgba5551[4];
	ScePspRGB565 	rgb565[4];
};

align(16) union ScePspUnion128 {
/*	SceULong128 	qw;*/	/* Missing compiler support. */
/*	SceULong128 	uq;*/
/*	SceLong128 	q;*/
	SceULong64		ul[2];
	SceLong64		l[2];
	uint 	ui[4];
	int 	i[4];
	ushort 	us[8];
	short	s[8];
	ubyte 	uc[16];
	byte 	c[16];
	float	f[4];
	ScePspFRect 	fr;
	ScePspIRect 	ir;
	ScePspFVector4 	fv;
	ScePspIVector4 	iv;
	ScePspFQuaternion fq;
	ScePspFColor 	fc;
	ScePspRGBA8888 	rgba8888[4];
	ScePspRGBA4444 	rgba4444[8];
	ScePspRGBA5551 	rgba5551[8];
	ScePspRGB565 	rgb565[8];
};

/* Date and time. */
struct ScePspDateTime {
	ushort	year;
	ushort 	month;
	ushort 	day;
	ushort 	hour;
	ushort 	minute;
	ushort 	second;
	uint 	microsecond;
};


