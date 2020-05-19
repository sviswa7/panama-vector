dnl Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
dnl Copyright (c) 2020, Arm Limited. All rights reserved.
dnl DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
dnl
dnl This code is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License version 2 only, as
dnl published by the Free Software Foundation.
dnl
dnl This code is distributed in the hope that it will be useful, but WITHOUT
dnl ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
dnl FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
dnl version 2 for more details (a copy is included in the LICENSE file that
dnl accompanied this code).
dnl
dnl You should have received a copy of the GNU General Public License version
dnl 2 along with this work; if not, write to the Free Software Foundation,
dnl Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
dnl
dnl Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
dnl or visit www.oracle.com if you need additional information or have any
dnl questions.
dnl
dnl
dnl Process this file with m4 ad_vector.m4 to generate vector instructions.
dnl
// BEGIN This section of the file is automatically generated. Do not edit --------------
// This section is generated from aarch64_neon_ad.m4
dnl
define(`ORL2I', `ifelse($1,I,orL2I)')dnl
dnl
define(`error', `__program__:__file__:__line__: Invalid argument ``$1''m4exit(`1')')dnl
dnl
define(`iTYPE2SIMD',
`ifelse($1, `B', `B',
        $1, `S', `H',
        $1, `I', `S',
        $1, `L', `D',
        `error($1)')')dnl
dnl
define(`fTYPE2SIMD',
`ifelse($1, `F', `S',
        $1, `D', `D',
        `error($1)')')dnl
dnl
define(`TYPE2DATATYPE',
`ifelse($1, `B', `BYTE',
        $1, `S', `SHORT',
        $1, `I', `INT',
        $1, `L', `LONG',
        $1, `F', `FLOAT',
        $1, `D', `DOUBLE',
        `error($1)')')dnl
dnl

// ====================VECTOR INSTRUCTIONS==================================

// ------------------------------ Load/store/reinterpret -----------------------

// Load vector (16 bits)
instruct loadV2(vecD dst, memory mem)
%{
  predicate(n->as_LoadVector()->memory_size() == 2);
  match(Set dst (LoadVector mem));
  ins_cost(4 * INSN_COST);
  format %{ "ldrh   $dst,$mem\t# vector (16 bits)" %}
  ins_encode( aarch64_enc_ldrvH(dst, mem) );
  ins_pipe(vload_reg_mem64);
%}

// Store Vector (16 bits)
instruct storeV2(vecD src, memory mem)
%{
  predicate(n->as_StoreVector()->memory_size() == 2);
  match(Set mem (StoreVector mem src));
  ins_cost(4 * INSN_COST);
  format %{ "strh   $mem,$src\t# vector (16 bits)" %}
  ins_encode( aarch64_enc_strvH(src, mem) );
  ins_pipe(vstore_reg_mem64);
%}
dnl
define(`REINTERPRET', `
instruct reinterpret$1`'(vec$1 dst)
%{
  predicate(n->bottom_type()->is_vect()->length_in_bytes() == $2 &&
            n->in(1)->bottom_type()->is_vect()->length_in_bytes() == $2);
  match(Set dst (VectorReinterpret dst));
  ins_cost(0);
  format %{ " # reinterpret $dst" %}
  ins_encode %{
    // empty
  %}
  ins_pipe(pipe_class_empty);
%}')dnl
dnl         $1 $2
REINTERPRET(D, 8)
REINTERPRET(X, 16)
dnl
define(`REINTERPRET_X', `
instruct reinterpret$1`'2$2`'(vec$2 dst, vec$1 src)
%{
  predicate(n->bottom_type()->is_vect()->length_in_bytes() == $3 &&
            n->in(1)->bottom_type()->is_vect()->length_in_bytes() == $4);
  match(Set dst (VectorReinterpret src));
  ins_cost(INSN_COST);
  format %{ " # reinterpret $dst,$src" %}
  ins_encode %{
    // If register is the same, then move is not needed.
    if (as_FloatRegister($dst$$reg) != as_FloatRegister($src$$reg)) {
      __ orr(as_FloatRegister($dst$$reg), __ T8B,
             as_FloatRegister($src$$reg),
             as_FloatRegister($src$$reg));
    }
  %}
  ins_pipe(vlogical64);
%}')dnl
dnl           $1 $2 $3  $4
REINTERPRET_X(D, X, 16, 8)
REINTERPRET_X(X, D, 8,  16)
dnl

// ------------------------------ Vector cast -------------------------------
dnl
define(`VECTOR_CAST_I2I', `
instruct vcvt$1$2to$1$3`'(vec$4 dst, vec$5 src)
%{
  predicate(n->as_Vector()->length() == $1 && n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorCast$2`'2X src));
  format %{ "$6  $dst, T$8, $src, T$7\t# convert $1$2 to $1$3 vector" %}
  ins_encode %{
    __ $6(as_FloatRegister($dst$$reg), __ T$8, as_FloatRegister($src$$reg), __ T$7);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1 $2 $3 $4 $5 $6    $7  $8
VECTOR_CAST_I2I(4, B, S, D, D, sxtl, 8B, 8H)
VECTOR_CAST_I2I(8, B, S, X, D, sxtl, 8B, 8H)
VECTOR_CAST_I2I(4, S, B, D, D, xtn,  8H, 8B)
VECTOR_CAST_I2I(8, S, B, D, X, xtn,  8H, 8B)
VECTOR_CAST_I2I(4, S, I, X, D, sxtl, 4H, 4S)
VECTOR_CAST_I2I(4, I, S, D, X, xtn,  4S, 4H)
VECTOR_CAST_I2I(2, I, L, X, D, sxtl, 2S, 2D)
VECTOR_CAST_I2I(2, L, I, D, X, xtn,  2D, 2S)
dnl
define(`VECTOR_CAST_B2I', `
instruct vcvt4$1to4$2`'(vec$3 dst, vec$4 src)
%{
  predicate(n->as_Vector()->length() == 4 && n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($2));
  match(Set dst (VectorCast$1`'2X src));
  format %{ "$5  $dst, T$7, $src, T$6\n\t"
            "$5  $dst, T$9, $dst, T$8\t# convert 4$1 to 4$2 vector"
  %}
  ins_encode %{
    __ $5(as_FloatRegister($dst$$reg), __ T$7, as_FloatRegister($src$$reg), __ T$6);
    __ $5(as_FloatRegister($dst$$reg), __ T$9, as_FloatRegister($dst$$reg), __ T$8);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1 $2 $3 $4 $5    $6  $7  $8  $9
VECTOR_CAST_B2I(B, I, X, D, sxtl, 8B, 8H, 4H, 4S)
VECTOR_CAST_B2I(I, B, D, X, xtn,  4S, 4H, 8H, 8B)

instruct vcvt4Bto4F(vecX dst, vecD src)
%{
  predicate(n->as_Vector()->length() == 4 && n->bottom_type()->is_vect()->element_basic_type() == T_FLOAT);
  match(Set dst (VectorCastB2X src));
  format %{ "sxtl  $dst, T8H, $src, T8B\n\t"
            "sxtl  $dst, T4S, $dst, T4H\n\t"
            "scvtfv  T4S, $dst, $dst\t# convert 4B to 4F vector"
  %}
  ins_encode %{
    __ sxtl(as_FloatRegister($dst$$reg), __ T8H, as_FloatRegister($src$$reg), __ T8B);
    __ sxtl(as_FloatRegister($dst$$reg), __ T4S, as_FloatRegister($dst$$reg), __ T4H);
    __ scvtfv(__ T4S, as_FloatRegister($dst$$reg), as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}
dnl
define(`VECTOR_CAST_I2F_L', `
instruct vcvt$1$2to$1$3`'(vecX dst, vecD src)
%{
  predicate(n->as_Vector()->length() == $1 && n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorCast$2`'2X src));
  format %{ "sxtl    $dst, T$5, $src, T$4\n\t"
            "scvtfv  T$5, $dst, $dst\t# convert $1$2 to $1$3 vector"
  %}
  ins_encode %{
    __ sxtl(as_FloatRegister($dst$$reg), __ T$5, as_FloatRegister($src$$reg), __ T$4);
    __ scvtfv(__ T$5, as_FloatRegister($dst$$reg), as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl               $1 $2 $3 $4  $5
VECTOR_CAST_I2F_L(4, S, F, 4H, 4S)
VECTOR_CAST_I2F_L(2, I, D, 2S, 2D)
dnl
define(`VECTOR_CAST_I2F', `
instruct vcvt$1$2to$1$3`'(vec$4 dst, vec$4 src)
%{
  predicate(n->as_Vector()->length() == $1 && n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorCast$2`'2X src));
  format %{ "scvtfv  T$5, $dst, $src\t# convert $1$2 to $1$3 vector" %}
  ins_encode %{
    __ scvtfv(__ T$5, as_FloatRegister($dst$$reg), as_FloatRegister($src$$reg));
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1 $2 $3 $4 $5
VECTOR_CAST_I2F(2, I, F, D, 2S)
VECTOR_CAST_I2F(4, I, F, X, 4S)
VECTOR_CAST_I2F(2, L, D, X, 2D)
dnl
define(`VECTOR_CAST_F2F', `
instruct vcvt2$1to2$2`'(vec$3 dst, vec$4 src)
%{
  predicate(n->as_Vector()->length() == 2 && n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($2));
  match(Set dst (VectorCast$1`'2X src));
  format %{ "$5  $dst, T$7, $src, T$6\t# convert 2$1 to 2$2 vector" %}
  ins_encode %{
    __ $5(as_FloatRegister($dst$$reg), __ T$7, as_FloatRegister($src$$reg), __ T$6);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1 $2 $3 $4 $5     $6  $7
VECTOR_CAST_F2F(F, D, X, D, fcvtl, 2S, 2D)
VECTOR_CAST_F2F(D, F, D, X, fcvtn, 2D, 2S)
dnl

instruct vcvt2Lto2F(vecD dst, vecX src)
%{
  predicate(n->as_Vector()->length() == 2 && n->bottom_type()->is_vect()->element_basic_type() == T_FLOAT);
  match(Set dst (VectorCastL2X src));
  format %{ "scvtfv  T2D, $dst, $src\n\t"
            "fcvtn   $dst, T2S, $dst, T2D\t# convert 2L to 2F vector"
  %}
  ins_encode %{
    __ scvtfv(__ T2D, as_FloatRegister($dst$$reg), as_FloatRegister($src$$reg));
    __ fcvtn(as_FloatRegister($dst$$reg), __ T2S, as_FloatRegister($dst$$reg), __ T2D);
  %}
  ins_pipe(pipe_slow);
%}

// ------------------------------ Reduction -------------------------------
dnl
define(`REDUCE_ADD_BORS', `
instruct reduce_add$1$2`'(iRegINoSp dst, iRegIorL2I isrc, vec$3 vsrc, vec$3 tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($2));
  match(Set dst (AddReductionVI isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "addv  $tmp, T$1`'iTYPE2SIMD($2), $vsrc\n\t"
            "smov  $dst, $tmp, iTYPE2SIMD($2), 0\n\t"
            "addw  $dst, $dst, $isrc\n\t"
            "sxt$4  $dst, $dst\t# add reduction$1$2"
  %}
  ins_encode %{
    __ addv(as_FloatRegister($tmp$$reg), __ T$1`'iTYPE2SIMD($2), as_FloatRegister($vsrc$$reg));
    __ smov($dst$$Register, as_FloatRegister($tmp$$reg), __ iTYPE2SIMD($2), 0);
    __ addw($dst$$Register, $dst$$Register, $isrc$$Register);
    __ sxt$4($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1  $2 $3 $4
REDUCE_ADD_BORS(8,  B, D, b)
REDUCE_ADD_BORS(16, B, X, b)
REDUCE_ADD_BORS(4,  S, D, h)
REDUCE_ADD_BORS(8,  S, X, h)
dnl

instruct reduce_add2L(iRegLNoSp dst, iRegL isrc, vecX vsrc, vecX tmp)
%{
  match(Set dst (AddReductionVL isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "addpd $tmp, $vsrc\n\t"
            "umov  $dst, $tmp, D, 0\n\t"
            "add   $dst, $isrc, $dst\t# add reduction2L"
  %}
  ins_encode %{
    __ addpd(as_FloatRegister($tmp$$reg), as_FloatRegister($vsrc$$reg));
    __ umov($dst$$Register, as_FloatRegister($tmp$$reg), __ D, 0);
    __ add($dst$$Register, $isrc$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}

instruct reduce_mul8B(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, vecD vtmp1, vecD vtmp2, iRegINoSp itmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst (MulReductionVI isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP vtmp1, TEMP vtmp2, TEMP itmp);
  format %{ "ins   $vtmp1, S, $vsrc, 0, 1\n\t"
            "mulv  $vtmp1, T8B, $vtmp1, $vsrc\n\t"
            "ins   $vtmp2, H, $vtmp1, 0, 1\n\t"
            "mulv  $vtmp2, T8B, $vtmp2, $vtmp1\n\t"
            "umov  $itmp, $vtmp2, B, 0\n\t"
            "mulw  $dst, $itmp, $isrc\n\t"
            "sxtb  $dst, $dst\n\t"
            "umov  $itmp, $vtmp2, B, 1\n\t"
            "mulw  $dst, $itmp, $dst\n\t"
            "sxtb  $dst, $dst\t# mul reduction8B"
  %}
  ins_encode %{
    __ ins(as_FloatRegister($vtmp1$$reg), __ S,
           as_FloatRegister($vsrc$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp1$$reg), __ T8B,
            as_FloatRegister($vtmp1$$reg), as_FloatRegister($vsrc$$reg));
    __ ins(as_FloatRegister($vtmp2$$reg), __ H,
           as_FloatRegister($vtmp1$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp2$$reg), __ T8B,
            as_FloatRegister($vtmp2$$reg), as_FloatRegister($vtmp1$$reg));
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ B, 0);
    __ mulw($dst$$Register, $itmp$$Register, $isrc$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ B, 1);
    __ mulw($dst$$Register, $itmp$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}

instruct reduce_mul16B(iRegINoSp dst, iRegIorL2I isrc, vecX vsrc, vecX vtmp1, vecX vtmp2, iRegINoSp itmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst (MulReductionVI isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP vtmp1, TEMP vtmp2, TEMP itmp);
  format %{ "ins   $vtmp1, D, $vsrc, 0, 1\n\t"
            "mulv  $vtmp1, T8B, $vtmp1, $vsrc\n\t"
            "ins   $vtmp2, S, $vtmp1, 0, 1\n\t"
            "mulv  $vtmp1, T8B, $vtmp2, $vtmp1\n\t"
            "ins   $vtmp2, H, $vtmp1, 0, 1\n\t"
            "mulv  $vtmp2, T8B, $vtmp2, $vtmp1\n\t"
            "umov  $itmp, $vtmp2, B, 0\n\t"
            "mulw  $dst, $itmp, $isrc\n\t"
            "sxtb  $dst, $dst\n\t"
            "umov  $itmp, $vtmp2, B, 1\n\t"
            "mulw  $dst, $itmp, $dst\n\t"
            "sxtb  $dst, $dst\t# mul reduction16B"
  %}
  ins_encode %{
    __ ins(as_FloatRegister($vtmp1$$reg), __ D,
           as_FloatRegister($vsrc$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp1$$reg), __ T8B,
            as_FloatRegister($vtmp1$$reg), as_FloatRegister($vsrc$$reg));
    __ ins(as_FloatRegister($vtmp2$$reg), __ S,
           as_FloatRegister($vtmp1$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp1$$reg), __ T8B,
            as_FloatRegister($vtmp2$$reg), as_FloatRegister($vtmp1$$reg));
    __ ins(as_FloatRegister($vtmp2$$reg), __ H,
           as_FloatRegister($vtmp1$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp2$$reg), __ T8B,
            as_FloatRegister($vtmp2$$reg), as_FloatRegister($vtmp1$$reg));
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ B, 0);
    __ mulw($dst$$Register, $itmp$$Register, $isrc$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ B, 1);
    __ mulw($dst$$Register, $itmp$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}

instruct reduce_mul4S(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, vecD vtmp, iRegINoSp itmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst (MulReductionVI isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP vtmp, TEMP itmp);
  format %{ "ins   $vtmp, S, $vsrc, 0, 1\n\t"
            "mulv  $vtmp, T4H, $vtmp, $vsrc\n\t"
            "umov  $itmp, $vtmp, H, 0\n\t"
            "mulw  $dst, $itmp, $isrc\n\t"
            "sxth  $dst, $dst\n\t"
            "umov  $itmp, $vtmp, H, 1\n\t"
            "mulw  $dst, $itmp, $dst\n\t"
            "sxth  $dst, $dst\t# mul reduction4S"
  %}
  ins_encode %{
    __ ins(as_FloatRegister($vtmp$$reg), __ S,
           as_FloatRegister($vsrc$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp$$reg), __ T4H,
            as_FloatRegister($vtmp$$reg), as_FloatRegister($vsrc$$reg));
    __ umov($itmp$$Register, as_FloatRegister($vtmp$$reg), __ H, 0);
    __ mulw($dst$$Register, $itmp$$Register, $isrc$$Register);
    __ sxth($dst$$Register, $dst$$Register);
    __ umov($itmp$$Register, as_FloatRegister($vtmp$$reg), __ H, 1);
    __ mulw($dst$$Register, $itmp$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}

instruct reduce_mul8S(iRegINoSp dst, iRegIorL2I isrc, vecX vsrc, vecX vtmp1, vecX vtmp2, iRegINoSp itmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst (MulReductionVI isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP vtmp1, TEMP vtmp2, TEMP itmp);
  format %{ "ins   $vtmp1, D, $vsrc, 0, 1\n\t"
            "mulv  $vtmp1, T4H, $vtmp1, $vsrc\n\t"
            "ins   $vtmp2, S, $vtmp1, 0, 1\n\t"
            "mulv  $vtmp2, T4H, $vtmp2, $vtmp1\n\t"
            "umov  $itmp, $vtmp2, H, 0\n\t"
            "mulw  $dst, $itmp, $isrc\n\t"
            "sxth  $dst, $dst\n\t"
            "umov  $itmp, $vtmp2, H, 1\n\t"
            "mulw  $dst, $itmp, $dst\n\t"
            "sxth  $dst, $dst\t# mul reduction8S"
  %}
  ins_encode %{
    __ ins(as_FloatRegister($vtmp1$$reg), __ D,
           as_FloatRegister($vsrc$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp1$$reg), __ T4H,
            as_FloatRegister($vtmp1$$reg), as_FloatRegister($vsrc$$reg));
    __ ins(as_FloatRegister($vtmp2$$reg), __ S,
           as_FloatRegister($vtmp1$$reg), 0, 1);
    __ mulv(as_FloatRegister($vtmp2$$reg), __ T4H,
            as_FloatRegister($vtmp2$$reg), as_FloatRegister($vtmp1$$reg));
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ H, 0);
    __ mulw($dst$$Register, $itmp$$Register, $isrc$$Register);
    __ sxth($dst$$Register, $dst$$Register);
    __ umov($itmp$$Register, as_FloatRegister($vtmp2$$reg), __ H, 1);
    __ mulw($dst$$Register, $itmp$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}

instruct reduce_mul2L(iRegLNoSp dst, iRegL isrc, vecX vsrc, iRegLNoSp tmp)
%{
  match(Set dst (MulReductionVL isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov  $tmp, $vsrc, D, 0\n\t"
            "mul   $dst, $isrc, $tmp\n\t"
            "umov  $tmp, $vsrc, D, 1\n\t"
            "mul   $dst, $dst, $tmp\t# mul reduction2L"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 0);
    __ mul($dst$$Register, $isrc$$Register, $tmp$$Register);
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 1);
    __ mul($dst$$Register, $dst$$Register, $tmp$$Register);
  %}
  ins_pipe(pipe_slow);
%}
dnl
define(`REDUCE_MAX_MIN_INT', `
instruct reduce_$1$2$3`'(iRegINoSp dst, iRegIorL2I isrc, vec$4 vsrc, vec$4 tmp, rFlagsReg cr)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst ($5ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp, KILL cr);
  format %{ "s$1v $tmp, T$2`'iTYPE2SIMD($3), $vsrc\n\t"
            "$6mov  $dst, $tmp, iTYPE2SIMD($3), 0\n\t"
            "cmpw  $dst, $isrc\n\t"
            "cselw $dst, $dst, $isrc $7\t# $1 reduction$2$3"
  %}
  ins_encode %{
    __ s$1v(as_FloatRegister($tmp$$reg), __ T$2`'iTYPE2SIMD($3), as_FloatRegister($vsrc$$reg));
    __ $6mov(as_Register($dst$$reg), as_FloatRegister($tmp$$reg), __ iTYPE2SIMD($3), 0);
    __ cmpw(as_Register($dst$$reg), as_Register($isrc$$reg));
    __ cselw(as_Register($dst$$reg), as_Register($dst$$reg), as_Register($isrc$$reg), Assembler::$7);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2  $3 $4 $5   $6 $7
REDUCE_MAX_MIN_INT(max, 8,  B, D, Max, s, GT)
REDUCE_MAX_MIN_INT(max, 16, B, X, Max, s, GT)
REDUCE_MAX_MIN_INT(max, 4,  S, D, Max, s, GT)
REDUCE_MAX_MIN_INT(max, 8,  S, X, Max, s, GT)
REDUCE_MAX_MIN_INT(max, 4,  I, X, Max, u, GT)
REDUCE_MAX_MIN_INT(min, 8,  B, D, Min, s, LT)
REDUCE_MAX_MIN_INT(min, 16, B, X, Min, s, LT)
REDUCE_MAX_MIN_INT(min, 4,  S, D, Min, s, LT)
REDUCE_MAX_MIN_INT(min, 8,  S, X, Min, s, LT)
REDUCE_MAX_MIN_INT(min, 4,  I, X, Min, u, LT)
dnl
define(`REDUCE_MAX_MIN_2I', `
instruct reduce_$1`'2I(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, vecX tmp, rFlagsReg cr)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_INT);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp, KILL cr);
  format %{ "dup   $tmp, T2D, $vsrc\n\t"
            "s$1v $tmp, T4S, $tmp\n\t"
            "umov  $dst, $tmp, S, 0\n\t"
            "cmpw  $dst, $isrc\n\t"
            "cselw $dst, $dst, $isrc $3\t# $1 reduction2I"
  %}
  ins_encode %{
    __ dup(as_FloatRegister($tmp$$reg), __ T2D, as_FloatRegister($vsrc$$reg));
    __ s$1v(as_FloatRegister($tmp$$reg), __ T4S, as_FloatRegister($tmp$$reg));
    __ umov(as_Register($dst$$reg), as_FloatRegister($tmp$$reg), __ S, 0);
    __ cmpw(as_Register($dst$$reg), as_Register($isrc$$reg));
    __ cselw(as_Register($dst$$reg), as_Register($dst$$reg), as_Register($isrc$$reg), Assembler::$3);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl               $1   $2   $3
REDUCE_MAX_MIN_2I(max, Max, GT)
REDUCE_MAX_MIN_2I(min, Min, LT)
dnl
define(`REDUCE_MAX_MIN_2L', `
instruct reduce_$1`'2L(iRegLNoSp dst, iRegL isrc, vecX vsrc, iRegLNoSp tmp, rFlagsReg cr)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_LONG);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp, KILL cr);
  format %{ "umov  $tmp, $vsrc, D, 0\n\t"
            "cmp   $isrc,$tmp\n\t"
            "csel  $dst, $isrc, $tmp $3\n\t"
            "umov  $tmp, $vsrc, D, 1\n\t"
            "cmp   $dst, $tmp\n\t"
            "csel  $dst, $dst, $tmp $3\t# $1 reduction2L"
  %}
  ins_encode %{
    __ umov(as_Register($tmp$$reg), as_FloatRegister($vsrc$$reg), __ D, 0);
    __ cmp(as_Register($isrc$$reg), as_Register($tmp$$reg));
    __ csel(as_Register($dst$$reg), as_Register($isrc$$reg), as_Register($tmp$$reg), Assembler::$3);
    __ umov(as_Register($tmp$$reg), as_FloatRegister($vsrc$$reg), __ D, 1);
    __ cmp(as_Register($dst$$reg), as_Register($tmp$$reg));
    __ csel(as_Register($dst$$reg), as_Register($dst$$reg), as_Register($tmp$$reg), Assembler::$3);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl               $1   $2   $3
REDUCE_MAX_MIN_2L(max, Max, GT)
REDUCE_MAX_MIN_2L(min, Min, LT)
dnl
define(`REDUCE_LOGIC_OP_8B', `
instruct reduce_$1`'8B(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $vsrc, S, 0\n\t"
            "umov   $dst, $vsrc, S, 1\n\t"
            "$1w   $dst, $dst, $tmp\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $dst, $dst, LSR #8\n\t"
            "$1w   $dst, $isrc, $dst\n\t"
            "sxtb   $dst, $dst\t# $1 reduction8B"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ S, 0);
    __ umov($dst$$Register, as_FloatRegister($vsrc$$reg), __ S, 1);
    __ $1w($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 8);
    __ $1w($dst$$Register, $isrc$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_8B(and, And)
REDUCE_LOGIC_OP_8B(orr, Or)
REDUCE_LOGIC_OP_8B(eor, Xor)
define(`REDUCE_LOGIC_OP_16B', `
instruct reduce_$1`'16B(iRegINoSp dst, iRegIorL2I isrc, vecX vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $vsrc, D, 0\n\t"
            "umov   $dst, $vsrc, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $dst, $dst, LSR #8\n\t"
            "$1w   $dst, $isrc, $dst\n\t"
            "sxtb   $dst, $dst\t# $1 reduction16B"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($vsrc$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 8);
    __ $1w($dst$$Register, $isrc$$Register, $dst$$Register);
    __ sxtb($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                 $1   $2   $3
REDUCE_LOGIC_OP_16B(and, And, andr)
REDUCE_LOGIC_OP_16B(orr, Or,  orr )
REDUCE_LOGIC_OP_16B(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_4S', `
instruct reduce_$1`'4S(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $vsrc, S, 0\n\t"
            "umov   $dst, $vsrc, S, 1\n\t"
            "$1w   $dst, $dst, $tmp\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $isrc, $dst\n\t"
            "sxth   $dst, $dst\t# $1 reduction4S"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ S, 0);
    __ umov($dst$$Register, as_FloatRegister($vsrc$$reg), __ S, 1);
    __ $1w($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $isrc$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_4S(and, And)
REDUCE_LOGIC_OP_4S(orr, Or)
REDUCE_LOGIC_OP_4S(eor, Xor)
dnl
define(`REDUCE_LOGIC_OP_8S', `
instruct reduce_$1`'8S(iRegINoSp dst, iRegIorL2I isrc, vecX vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $vsrc, D, 0\n\t"
            "umov   $dst, $vsrc, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $dst, $dst, LSR #16\n\t"
            "$1w   $dst, $isrc, $dst\n\t"
            "sxth   $dst, $dst\t# $1 reduction8S"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($vsrc$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 16);
    __ $1w($dst$$Register, $isrc$$Register, $dst$$Register);
    __ sxth($dst$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_8S(and, And, andr)
REDUCE_LOGIC_OP_8S(orr, Or,  orr )
REDUCE_LOGIC_OP_8S(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_2I', `
instruct reduce_$1`'2I(iRegINoSp dst, iRegIorL2I isrc, vecD vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_INT);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov  $tmp, $vsrc, S, 0\n\t"
            "$1w  $dst, $tmp, $isrc\n\t"
            "umov  $tmp, $vsrc, S, 1\n\t"
            "$1w  $dst, $tmp, $dst\t# $1 reduction2I"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ S, 0);
    __ $1w($dst$$Register, $tmp$$Register, $isrc$$Register);
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ S, 1);
    __ $1w($dst$$Register, $tmp$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2
REDUCE_LOGIC_OP_2I(and, And)
REDUCE_LOGIC_OP_2I(orr, Or)
REDUCE_LOGIC_OP_2I(eor, Xor)
dnl
define(`REDUCE_LOGIC_OP_4I', `
instruct reduce_$1`'4I(iRegINoSp dst, iRegIorL2I isrc, vecX vsrc, iRegINoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_INT);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov   $tmp, $vsrc, D, 0\n\t"
            "umov   $dst, $vsrc, D, 1\n\t"
            "$3   $dst, $dst, $tmp\n\t"
            "$3   $dst, $dst, $dst, LSR #32\n\t"
            "$1w   $dst, $isrc, $dst\t# $1 reduction4I"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 0);
    __ umov($dst$$Register, as_FloatRegister($vsrc$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
    __ $3($dst$$Register, $dst$$Register, $dst$$Register, Assembler::LSR, 32);
    __ $1w($dst$$Register, $isrc$$Register, $dst$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_4I(and, And, andr)
REDUCE_LOGIC_OP_4I(orr, Or,  orr )
REDUCE_LOGIC_OP_4I(eor, Xor, eor )
dnl
define(`REDUCE_LOGIC_OP_2L', `
instruct reduce_$1`'2L(iRegLNoSp dst, iRegL isrc, vecX vsrc, iRegLNoSp tmp)
%{
  predicate(n->in(2)->bottom_type()->is_vect()->element_basic_type() == T_LONG);
  match(Set dst ($2ReductionV isrc vsrc));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp);
  format %{ "umov  $tmp, $vsrc, D, 0\n\t"
            "$3  $dst, $isrc, $tmp\n\t"
            "umov  $tmp, $vsrc, D, 1\n\t"
            "$3  $dst, $dst, $tmp\t# $1 reduction2L"
  %}
  ins_encode %{
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 0);
    __ $3($dst$$Register, $isrc$$Register, $tmp$$Register);
    __ umov($tmp$$Register, as_FloatRegister($vsrc$$reg), __ D, 1);
    __ $3($dst$$Register, $dst$$Register, $tmp$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1   $2   $3
REDUCE_LOGIC_OP_2L(and, And, andr)
REDUCE_LOGIC_OP_2L(orr, Or,  orr )
REDUCE_LOGIC_OP_2L(eor, Xor, eor )
dnl

// ------------------------------ Vector insert ---------------------------------
define(`VECTOR_INSERT_I', `
instruct insert$1$2`'(vec$3 dst, vec$3 src, iReg$4`'ORL2I($4) val, immI idx)
%{
  predicate(n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($2));
  match(Set dst (VectorInsert (Binary src val) idx));
  ins_cost(INSN_COST);
  format %{ "orr    $dst, T$5, $src, $src\n\t"
            "mov    $dst, T$1`'iTYPE2SIMD($2), $idx, $val\t# insert into vector($1$2)" %}
  ins_encode %{
    if (as_FloatRegister($dst$$reg) != as_FloatRegister($src$$reg)) {
      __ orr(as_FloatRegister($dst$$reg), __ T$5,
             as_FloatRegister($src$$reg), as_FloatRegister($src$$reg));
    }
    __ mov(as_FloatRegister($dst$$reg), __ T$1`'iTYPE2SIMD($2), $idx$$constant, $val$$Register);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1  $2 $3 $4 $5
VECTOR_INSERT_I(8,  B, D, I, 8B)
VECTOR_INSERT_I(16, B, X, I, 16B)
VECTOR_INSERT_I(4,  S, D, I, 8B)
VECTOR_INSERT_I(8,  S, X, I, 16B)
VECTOR_INSERT_I(2,  I, D, I, 8B)
VECTOR_INSERT_I(4,  I, X, I, 16B)
VECTOR_INSERT_I(2,  L, X, L, 16B)
dnl
define(`VECTOR_INSERT_F', `
instruct insert$1`'(vec$2 dst, vec$2 src, vReg$3 val, immI idx)
%{
  predicate(n->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorInsert (Binary src val) idx));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst);
  format %{ "orr    $dst, T$4, $src, $src\n\t"
            "ins    $dst, $5, $val, $idx, 0\t# insert into vector($1)" %}
  ins_encode %{
    __ orr(as_FloatRegister($dst$$reg), __ T$4,
           as_FloatRegister($src$$reg), as_FloatRegister($src$$reg));
    __ ins(as_FloatRegister($dst$$reg), __ $5,
           as_FloatRegister($val$$reg), $idx$$constant, 0);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1  $2 $3 $4   $5
VECTOR_INSERT_F(2F, D, F, 8B,  S)
VECTOR_INSERT_F(4F, X, F, 16B, S)
VECTOR_INSERT_F(2D, X, D, 16B, D)
dnl

// ------------------------------ Vector extract ---------------------------------
define(`VECTOR_EXTRACT_I', `
instruct extract$1$2`'(iReg$3NoSp dst, vec$4 src, immI idx)
%{
  predicate(n->in(1)->bottom_type()->is_vect()->length() == $1);
  match(Set dst (Extract$2 src idx));
  ins_cost(INSN_COST);
  format %{ "$5mov    $dst, $src, $6, $idx\t# extract from vector($1$2)" %}
  ins_encode %{
    __ $5mov($dst$$Register, as_FloatRegister($src$$reg), __ $6, $idx$$constant);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1   $2 $3 $4 $5 $6
VECTOR_EXTRACT_I(8,  B, I, D, s, B)
VECTOR_EXTRACT_I(16, B, I, X, s, B)
VECTOR_EXTRACT_I(4,  S, I, D, s, H)
VECTOR_EXTRACT_I(8,  S, I, X, s, H)
VECTOR_EXTRACT_I(2,  I, I, D, u, S)
VECTOR_EXTRACT_I(4,  I, I, X, u, S)
VECTOR_EXTRACT_I(2,  L, L, X, u, D)
dnl
define(`VECTOR_EXTRACT_F', `
instruct extract$1$2`'(vReg$2 dst, vec$3 src, immI idx)
%{
  predicate(n->in(1)->bottom_type()->is_vect()->length() == $1);
  match(Set dst (Extract$2 src idx));
  ins_cost(INSN_COST);
  format %{ "ins   $dst, $4, $src, 0, $idx\t# extract from vector($1$2)" %}
  ins_encode %{
    __ ins(as_FloatRegister($dst$$reg), __ $4,
           as_FloatRegister($src$$reg), 0, $idx$$constant);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl             $1  $2 $3 $4
VECTOR_EXTRACT_F(2, F, D, S)
VECTOR_EXTRACT_F(4, F, X, S)
VECTOR_EXTRACT_F(2, D, X, D)
dnl

// ------------------------------ Vector comparison ---------------------------------
define(`VECTOR_CMP_EQ_GT_GE', `
instruct vcm$1$2$3`'(vec$4 dst, vec$4 src1, vec$4 src2, immI cond)
%{
  predicate(n->as_Vector()->length() == $2 &&
            n->as_VectorMaskCmp()->get_predicate() == BoolTest::$1 &&
            n->in(1)->in(1)->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorMaskCmp (Binary src1 src2) cond));
  format %{ "$6cm$1  $dst, $src1, $src2\t# vector cmp ($2$3)" %}
  ins_cost(INSN_COST);
  ins_encode %{
    __ $6cm$1(as_FloatRegister($dst$$reg), __ T$2$5,
            as_FloatRegister($src1$$reg), as_FloatRegister($src2$$reg));
  %}
  ins_pipe(vdop$7);
%}')dnl
dnl                $1   $2 $3 $4 $5 $6 $7
VECTOR_CMP_EQ_GT_GE(eq, 8, B, D, B,  , 64)
VECTOR_CMP_EQ_GT_GE(eq, 16,B, X, B,  , 128)
VECTOR_CMP_EQ_GT_GE(eq, 4, S, D, H,  , 64)
VECTOR_CMP_EQ_GT_GE(eq, 8, S, X, H,  , 128)
VECTOR_CMP_EQ_GT_GE(eq, 2, I, D, S,  , 64)
VECTOR_CMP_EQ_GT_GE(eq, 4, I, X, S,  , 128)
VECTOR_CMP_EQ_GT_GE(eq, 2, L, X, D,  , 128)
VECTOR_CMP_EQ_GT_GE(eq, 2, F, D, S, f, 64)
VECTOR_CMP_EQ_GT_GE(eq, 4, F, X, S, f, 128)
VECTOR_CMP_EQ_GT_GE(eq, 2, D, X, D, f, 128)
VECTOR_CMP_EQ_GT_GE(gt, 8, B, D, B,  , 64)
VECTOR_CMP_EQ_GT_GE(gt, 16,B, X, B,  , 128)
VECTOR_CMP_EQ_GT_GE(gt, 4, S, D, H,  , 64)
VECTOR_CMP_EQ_GT_GE(gt, 8, S, X, H,  , 128)
VECTOR_CMP_EQ_GT_GE(gt, 2, I, D, S,  , 64)
VECTOR_CMP_EQ_GT_GE(gt, 4, I, X, S,  , 128)
VECTOR_CMP_EQ_GT_GE(gt, 2, L, X, D,  , 128)
VECTOR_CMP_EQ_GT_GE(gt, 2, F, D, S, f, 64)
VECTOR_CMP_EQ_GT_GE(gt, 4, F, X, S, f, 128)
VECTOR_CMP_EQ_GT_GE(gt, 2, D, X, D, f, 128)
VECTOR_CMP_EQ_GT_GE(ge, 8, B, D, B,  , 64)
VECTOR_CMP_EQ_GT_GE(ge, 16,B, X, B,  , 128)
VECTOR_CMP_EQ_GT_GE(ge, 4, S, D, H,  , 64)
VECTOR_CMP_EQ_GT_GE(ge, 8, S, X, H,  , 128)
VECTOR_CMP_EQ_GT_GE(ge, 2, I, D, S,  , 64)
VECTOR_CMP_EQ_GT_GE(ge, 4, I, X, S,  , 128)
VECTOR_CMP_EQ_GT_GE(ge, 2, L, X, D,  , 128)
VECTOR_CMP_EQ_GT_GE(ge, 2, F, D, S, f, 64)
VECTOR_CMP_EQ_GT_GE(ge, 4, F, X, S, f, 128)
VECTOR_CMP_EQ_GT_GE(ge, 2, D, X, D, f, 128)
dnl
define(`VECTOR_CMP_NE', `
instruct vcmne$1$2`'(vec$3 dst, vec$3 src1, vec$3 src2, immI cond)
%{
  predicate(n->as_Vector()->length() == $1 &&
            n->as_VectorMaskCmp()->get_predicate() == BoolTest::ne &&
            n->in(1)->in(1)->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($2));
  match(Set dst (VectorMaskCmp (Binary src1 src2) cond));
  format %{ "$5cmeq  $dst, $src1, $src2\n\t# vector cmp ($1$2)"
            "not   $dst, $dst\t" %}
  ins_cost(INSN_COST);
  ins_encode %{
    __ $5cmeq(as_FloatRegister($dst$$reg), __ T$1$4,
            as_FloatRegister($src1$$reg), as_FloatRegister($src2$$reg));
    __ notr(as_FloatRegister($dst$$reg), __ T$6, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl           $1 $2 $3 $4 $5 $6
VECTOR_CMP_NE(8, B, D, B,  , 8B)
VECTOR_CMP_NE(16,B, X, B,  , 16B)
VECTOR_CMP_NE(4, S, D, H,  , 8B)
VECTOR_CMP_NE(8, S, X, H,  , 16B)
VECTOR_CMP_NE(2, I, D, S,  , 8B)
VECTOR_CMP_NE(4, I, X, S,  , 16B)
VECTOR_CMP_NE(2, L, X, D,  , 16B)
VECTOR_CMP_NE(2, F, D, S, f, 8B)
VECTOR_CMP_NE(4, F, X, S, f, 16B)
VECTOR_CMP_NE(2, D, X, D, f, 16B)
dnl
define(`VECTOR_CMP_LT_LE', `
instruct vcm$1$2$3`'(vec$4 dst, vec$4 src1, vec$4 src2, immI cond)
%{
  predicate(n->as_Vector()->length() == $2 &&
            n->as_VectorMaskCmp()->get_predicate() == BoolTest::$1 &&
            n->in(1)->in(1)->bottom_type()->is_vect()->element_basic_type() == T_`'TYPE2DATATYPE($3));
  match(Set dst (VectorMaskCmp (Binary src1 src2) cond));
  format %{ "$6cm$7  $dst, $src2, $src1\t# vector cmp ($2$3)" %}
  ins_cost(INSN_COST);
  ins_encode %{
    __ $6cm$7(as_FloatRegister($dst$$reg), __ T$2$5,
            as_FloatRegister($src2$$reg), as_FloatRegister($src1$$reg));
  %}
  ins_pipe(vdop$8);
%}')dnl
dnl              $1  $2 $3 $4 $5 $6 $7  $8
VECTOR_CMP_LT_LE(lt, 8, B, D, B,  , gt, 64)
VECTOR_CMP_LT_LE(lt, 16,B, X, B,  , gt, 128)
VECTOR_CMP_LT_LE(lt, 4, S, D, H,  , gt, 64)
VECTOR_CMP_LT_LE(lt, 8, S, X, H,  , gt, 128)
VECTOR_CMP_LT_LE(lt, 2, I, D, S,  , gt, 64)
VECTOR_CMP_LT_LE(lt, 4, I, X, S,  , gt, 128)
VECTOR_CMP_LT_LE(lt, 2, L, X, D,  , gt, 128)
VECTOR_CMP_LT_LE(lt, 2, F, D, S, f, gt, 64)
VECTOR_CMP_LT_LE(lt, 4, F, X, S, f, gt, 128)
VECTOR_CMP_LT_LE(lt, 2, D, X, D, f, gt, 128)
VECTOR_CMP_LT_LE(le, 8, B, D, B,  , ge, 64)
VECTOR_CMP_LT_LE(le, 16,B, X, B,  , ge, 128)
VECTOR_CMP_LT_LE(le, 4, S, D, H,  , ge, 64)
VECTOR_CMP_LT_LE(le, 8, S, X, H,  , ge, 128)
VECTOR_CMP_LT_LE(le, 2, I, D, S,  , ge, 64)
VECTOR_CMP_LT_LE(le, 4, I, X, S,  , ge, 128)
VECTOR_CMP_LT_LE(le, 2, L, X, D,  , ge, 128)
VECTOR_CMP_LT_LE(le, 2, F, D, S, f, ge, 64)
VECTOR_CMP_LT_LE(le, 4, F, X, S, f, ge, 128)
VECTOR_CMP_LT_LE(le, 2, D, X, D, f, ge, 128)
dnl

// ------------------------------ Vector mul -----------------------------------

instruct vmul2L(vecX dst, vecX src1, vecX src2, iRegLNoSp tmp1, iRegLNoSp tmp2)
%{
  predicate(n->as_Vector()->length() == 2);
  match(Set dst (MulVL src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP tmp1, TEMP tmp2);
  format %{ "umov   $tmp1, $src1, D, 0\n\t"
            "umov   $tmp2, $src2, D, 0\n\t"
            "mul    $tmp2, $tmp2, $tmp1\n\t"
            "mov    $dst,  T2D,   0, $tmp2\t# insert into vector(2L)\n\t"
            "umov   $tmp1, $src1, D, 1\n\t"
            "umov   $tmp2, $src2, D, 1\n\t"
            "mul    $tmp2, $tmp2, $tmp1\n\t"
            "mov    $dst,  T2D,   1, $tmp2\t# insert into vector(2L)\n\t"
  %}
  ins_encode %{
    __ umov($tmp1$$Register, as_FloatRegister($src1$$reg), __ D, 0);
    __ umov($tmp2$$Register, as_FloatRegister($src2$$reg), __ D, 0);
    __ mul(as_Register($tmp2$$reg), as_Register($tmp2$$reg), as_Register($tmp1$$reg));
    __ mov(as_FloatRegister($dst$$reg), __ T2D, 0, $tmp2$$Register);
    __ umov($tmp1$$Register, as_FloatRegister($src1$$reg), __ D, 1);
    __ umov($tmp2$$Register, as_FloatRegister($src2$$reg), __ D, 1);
    __ mul(as_Register($tmp2$$reg), as_Register($tmp2$$reg), as_Register($tmp1$$reg));
    __ mov(as_FloatRegister($dst$$reg), __ T2D, 1, $tmp2$$Register);
  %}
  ins_pipe(pipe_slow);
%}

// --------------------------------- Vector not --------------------------------
dnl
define(`MATCH_RULE', `ifelse($1, I,
`match(Set dst (XorV src (ReplicateB m1)));
  match(Set dst (XorV src (ReplicateS m1)));
  match(Set dst (XorV src (ReplicateI m1)));',
`match(Set dst (XorV src (ReplicateL m1)));')')dnl
dnl
define(`VECTOR_NOT', `
instruct vnot$1$2`'(vec$3 dst, vec$3 src, imm$2_M1 m1)
%{
  predicate(n->as_Vector()->length_in_bytes() == $4);
  MATCH_RULE($2)
  ins_cost(INSN_COST);
  format %{ "not  $dst, $src\t# vector ($5)" %}
  ins_encode %{
    __ notr(as_FloatRegister($dst$$reg), __ T$5,
            as_FloatRegister($src$$reg));
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl        $1 $2 $3 $4  $5
VECTOR_NOT(2, I, D, 8,  8B)
VECTOR_NOT(4, I, X, 16, 16B)
VECTOR_NOT(2, L, X, 16, 16B)
undefine(MATCH_RULE)
dnl
// ------------------------------ Vector max/min -------------------------------
dnl
define(`PREDICATE', `ifelse($1, 8B,
`predicate((n->as_Vector()->length() == 4 || n->as_Vector()->length() == 8) &&
             n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);',
`predicate(n->as_Vector()->length() == $2 && n->bottom_type()->is_vect()->element_basic_type() == T_$3);')')dnl
dnl
define(`VECTOR_MAX_MIN_INT', `
instruct v$1$2$3`'(vec$4 dst, vec$4 src1, vec$4 src2)
%{
  PREDICATE(`$2$3', $2, TYPE2DATATYPE($3))
  match(Set dst ($5V src1 src2));
  ins_cost(INSN_COST);
  format %{ "$1v  $dst, $src1, $src2\t# vector ($2$3)" %}
  ins_encode %{
    __ $1v(as_FloatRegister($dst$$reg), __ T$2`'iTYPE2SIMD($3),
            as_FloatRegister($src1$$reg),
            as_FloatRegister($src2$$reg));
  %}
  ins_pipe(vdop$6);
%}')dnl
dnl                $1   $2  $3 $4 $5   $6
VECTOR_MAX_MIN_INT(max, 8,  B, D, Max, 64)
VECTOR_MAX_MIN_INT(max, 16, B, X, Max, 128)
VECTOR_MAX_MIN_INT(max, 4,  S, D, Max, 64)
VECTOR_MAX_MIN_INT(max, 8,  S, X, Max, 128)
VECTOR_MAX_MIN_INT(max, 2,  I, D, Max, 64)
VECTOR_MAX_MIN_INT(max, 4,  I, X, Max, 128)
VECTOR_MAX_MIN_INT(min, 8,  B, D, Min, 64)
VECTOR_MAX_MIN_INT(min, 16, B, X, Min, 128)
VECTOR_MAX_MIN_INT(min, 4,  S, D, Min, 64)
VECTOR_MAX_MIN_INT(min, 8,  S, X, Min, 128)
VECTOR_MAX_MIN_INT(min, 2,  I, D, Min, 64)
VECTOR_MAX_MIN_INT(min, 4,  I, X, Min, 128)
undefine(PREDICATE)
dnl
define(`VECTOR_MAX_MIN_LONG', `
instruct v$1`'2L`'(vecX dst, vecX src1, vecX src2)
%{
  predicate(n->as_Vector()->length() == 2 && n->bottom_type()->is_vect()->element_basic_type() == T_LONG);
  match(Set dst ($2V src1 src2));
  ins_cost(INSN_COST);
  effect(TEMP dst);
  format %{ "cmgt  $dst, $src1, $src2\t# vector (2L)\n\t"
            "bsl   $dst, $$3, $$4\t# vector (16B)" %}
  ins_encode %{
    __ cmgt(as_FloatRegister($dst$$reg), __ T2D,
            as_FloatRegister($src1$$reg), as_FloatRegister($src2$$reg));
    __ bsl(as_FloatRegister($dst$$reg), __ T16B,
           as_FloatRegister($$3$$reg), as_FloatRegister($$4$$reg));
  %}
  ins_pipe(vdop128);
%}')dnl
dnl                $1   $2   $3    $4
VECTOR_MAX_MIN_LONG(max, Max, src1, src2)
VECTOR_MAX_MIN_LONG(min, Min, src2, src1)
dnl

// --------------------------------- blend (bsl) ----------------------------
dnl
define(`VECTOR_BSL', `
instruct vbsl$1B`'(vec$2 dst, vec$2 src1, vec$2 src2)
%{
  predicate(n->as_Vector()->length_in_bytes() == $1);
  match(Set dst (VectorBlend (Binary src1 src2) dst));
  ins_cost(INSN_COST);
  format %{ "bsl  $dst, $src2, $src1\t# vector ($1B)" %}
  ins_encode %{
    __ bsl(as_FloatRegister($dst$$reg), __ T$1B,
           as_FloatRegister($src2$$reg), as_FloatRegister($src1$$reg));
  %}
  ins_pipe(vlogical$3);
%}')dnl
dnl        $1  $2 $3
VECTOR_BSL(8,  D, 64)
VECTOR_BSL(16, X, 128)
dnl

// --------------------------------- Load/store Mask ----------------------------
dnl
define(`PREDICATE', `ifelse($1, load,
`predicate(n->as_Vector()->length() == $2 && n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);',
`predicate(n->as_Vector()->length() == $2);')')dnl
dnl
define(`VECTOR_LOAD_STORE_MASK_B', `
instruct $1mask$2B`'(vec$3 dst, vec$3 src $5 $6)
%{
  PREDICATE($1, $2)
  match(Set dst (Vector$4Mask src $6));
  ins_cost(INSN_COST);
  format %{ "negr  $dst, $src\t# $1 mask ($2B to $2B)" %}
  ins_encode %{
    __ negr(as_FloatRegister($dst$$reg), __ T$2B, as_FloatRegister($src$$reg));
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                      $1     $2  $3 $4     $5      $6
VECTOR_LOAD_STORE_MASK_B(load,  8,  D, Load)
VECTOR_LOAD_STORE_MASK_B(load,  16, X, Load)
VECTOR_LOAD_STORE_MASK_B(store, 8,  D, Store, `, immI_1', size)
VECTOR_LOAD_STORE_MASK_B(store, 16, X, Store, `, immI_1', size)
undefine(PREDICATE)dnl
dnl
define(`PREDICATE', `ifelse($1, load,
`predicate(n->as_Vector()->length() == $2 && n->bottom_type()->is_vect()->element_basic_type() == T_SHORT);',
`predicate(n->as_Vector()->length() == $2);')')dnl
dnl
define(`VECTOR_LOAD_STORE_MASK_S', `
instruct $1mask$2S`'(vec$3 dst, vec$4 src $9 $10)
%{
  PREDICATE($1, $2)
  match(Set dst (Vector$5Mask src $10));
  ins_cost(INSN_COST);
  format %{ "$6  $dst, $src\n\t"
            "negr  $dst, $dst\t# $1 mask ($2$7 to $2$8)" %}
  ins_encode %{
    __ $6(as_FloatRegister($dst$$reg), __ T8$8, as_FloatRegister($src$$reg), __ T8$7);
    __ negr(as_FloatRegister($dst$$reg), __ T8$8, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                      $1     $2 $3 $4 $5     $6    $7 $8    $9       $10
VECTOR_LOAD_STORE_MASK_S(load,  4, D, D, Load,  uxtl, B, H)
VECTOR_LOAD_STORE_MASK_S(load,  8, X, D, Load,  uxtl, B, H)
VECTOR_LOAD_STORE_MASK_S(store, 4, D, D, Store, xtn,  H, B, `, immI_2', size)
VECTOR_LOAD_STORE_MASK_S(store, 8, D, X, Store, xtn,  H, B, `, immI_2', size)
undefine(PREDICATE)dnl
dnl
define(`PREDICATE', `ifelse($1, load,
`predicate(n->as_Vector()->length() == $2 &&
            (n->bottom_type()->is_vect()->element_basic_type() == T_INT ||
             n->bottom_type()->is_vect()->element_basic_type() == T_FLOAT));',
`predicate(n->as_Vector()->length() == $2);')')dnl
dnl
define(`VECTOR_LOAD_STORE_MASK_I', `
instruct $1mask$2I`'(vec$3 dst, vec$4 src $12 $13)
%{
  PREDICATE($1, $2)
  match(Set dst (Vector$5Mask src $13));
  ins_cost(INSN_COST);
  format %{ "$6  $dst, $src\t# $2$7 to $2$8\n\t"
            "$6  $dst, $dst\t# $2$8 to $2$9\n\t"
            "negr   $dst, $dst\t# $1 mask ($2$7 to $2$9)" %}
  ins_encode %{
    __ $6(as_FloatRegister($dst$$reg), __ T$10$8, as_FloatRegister($src$$reg), __ T$10$7);
    __ $6(as_FloatRegister($dst$$reg), __ T$11$9, as_FloatRegister($dst$$reg), __ T$11$8);
    __ negr(as_FloatRegister($dst$$reg), __ T$11$9, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                      $1     $2 $3 $4 $5     $6    $7 $8 $9 $10$11   $12      $13
VECTOR_LOAD_STORE_MASK_I(load,  2, D, D, Load,  uxtl, B, H, S, 8, 4)
VECTOR_LOAD_STORE_MASK_I(load,  4, X, D, Load,  uxtl, B, H, S, 8, 4)
VECTOR_LOAD_STORE_MASK_I(store, 2, D, D, Store, xtn,  S, H, B, 4, 8, `, immI_4', size)
VECTOR_LOAD_STORE_MASK_I(store, 4, D, X, Store, xtn,  S, H, B, 4, 8, `, immI_4', size)
undefine(PREDICATE)
dnl
instruct loadmask2L(vecX dst, vecD src)
%{
  predicate(n->as_Vector()->length() == 2 &&
            (n->bottom_type()->is_vect()->element_basic_type() == T_LONG ||
             n->bottom_type()->is_vect()->element_basic_type() == T_DOUBLE));
  match(Set dst (VectorLoadMask src));
  ins_cost(INSN_COST);
  format %{ "uxtl  $dst, $src\t# 2B to 2S\n\t"
            "uxtl  $dst, $dst\t# 2S to 2I\n\t"
            "uxtl  $dst, $dst\t# 2I to 2L\n\t"
            "neg   $dst, $dst\t# load mask (2B to 2L)" %}
  ins_encode %{
    __ uxtl(as_FloatRegister($dst$$reg), __ T8H, as_FloatRegister($src$$reg), __ T8B);
    __ uxtl(as_FloatRegister($dst$$reg), __ T4S, as_FloatRegister($dst$$reg), __ T4H);
    __ uxtl(as_FloatRegister($dst$$reg), __ T2D, as_FloatRegister($dst$$reg), __ T2S);
    __ negr(as_FloatRegister($dst$$reg), __ T2D, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}

instruct storemask2L(vecD dst, vecX src, immI_8 size)
%{
  predicate(n->as_Vector()->length() == 2);
  match(Set dst (VectorStoreMask src size));
  ins_cost(INSN_COST);
  format %{ "xtn  $dst, $src\t# 2L to 2I\n\t"
            "xtn  $dst, $dst\t# 2I to 2S\n\t"
            "xtn  $dst, $dst\t# 2S to 2B\n\t"
            "neg  $dst, $dst\t# store mask (2L to 2B)" %}
  ins_encode %{
    __ xtn(as_FloatRegister($dst$$reg), __ T2S, as_FloatRegister($src$$reg), __ T2D);
    __ xtn(as_FloatRegister($dst$$reg), __ T4H, as_FloatRegister($dst$$reg), __ T4S);
    __ xtn(as_FloatRegister($dst$$reg), __ T8B, as_FloatRegister($dst$$reg), __ T8H);
    __ negr(as_FloatRegister($dst$$reg), __ T8B, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}

//-------------------------------- LOAD_IOTA_INDICES----------------------------------
dnl
define(`PREDICATE', `ifelse($1, 8,
`predicate((n->as_Vector()->length() == 2 || n->as_Vector()->length() == 4 ||
             n->as_Vector()->length() == 8) &&
             n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);',
`predicate(n->as_Vector()->length() == 16 && n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);')')dnl
dnl
define(`VECTOR_LOAD_CON', `
instruct loadcon$1B`'(vec$2 dst, immI0 src)
%{
  PREDICATE($1)
  match(Set dst (VectorLoadConst src));
  ins_cost(INSN_COST);
  format %{ "ldr $dst, CONSTANT_MEMORY\t# load iota indices" %}
  ins_encode %{
    __ lea(rscratch1, ExternalAddress(StubRoutines::aarch64::vector_iota_indices()));
    __ ldr$3(as_FloatRegister($dst$$reg), rscratch1);
  %}
  ins_pipe(pipe_class_memory);
%}')dnl
dnl             $1  $2 $3
VECTOR_LOAD_CON(8,  D, d)
VECTOR_LOAD_CON(16, X, q)
undefine(PREDICATE)
dnl
//-------------------------------- LOAD_SHUFFLE ----------------------------------
dnl
define(`VECTOR_LOAD_SHUFFLE_B', `
instruct loadshuffle$1B`'(vec$2 dst, vec$2 src)
%{
  predicate(n->as_Vector()->length() == $1 &&
            n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst (VectorLoadShuffle src));
  ins_cost(INSN_COST);
  format %{ "mov  $dst, $src\t# get $1B shuffle" %}
  ins_encode %{
    __ orr(as_FloatRegister($dst$$reg), __ T$1B,
           as_FloatRegister($src$$reg), as_FloatRegister($src$$reg));
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                   $1  $2
VECTOR_LOAD_SHUFFLE_B(8,  D)
VECTOR_LOAD_SHUFFLE_B(16, X)
dnl
define(`VECTOR_LOAD_SHUFFLE_S', `
instruct loadshuffle$1S`'(vec$2 dst, vec$3 src)
%{
  predicate(n->as_Vector()->length() == $1 &&
            n->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst (VectorLoadShuffle src));
  ins_cost(INSN_COST);
  format %{ "uxtl  $dst, $src\t# $1B to $1H" %}
  ins_encode %{
    __ uxtl(as_FloatRegister($dst$$reg), __ T8H, as_FloatRegister($src$$reg), __ T8B);
  %}
  ins_pipe(pipe_class_default);
%}')dnl
dnl                   $1 $2 $3
VECTOR_LOAD_SHUFFLE_S(4, D, D)
VECTOR_LOAD_SHUFFLE_S(8, X, D)
dnl

instruct loadshuffle4I(vecX dst, vecD src)
%{
  predicate(n->as_Vector()->length() == 4 &&
           (n->bottom_type()->is_vect()->element_basic_type() == T_INT ||
            n->bottom_type()->is_vect()->element_basic_type() == T_FLOAT));
  match(Set dst (VectorLoadShuffle src));
  ins_cost(INSN_COST);
  format %{ "uxtl  $dst, $src\t# 4B to 4H \n\t"
            "uxtl  $dst, $dst\t# 4H to 4S" %}
  ins_encode %{
    __ uxtl(as_FloatRegister($dst$$reg), __ T8H, as_FloatRegister($src$$reg), __ T8B);
    __ uxtl(as_FloatRegister($dst$$reg), __ T4S, as_FloatRegister($dst$$reg), __ T4H);
  %}
  ins_pipe(pipe_slow);
%}

//-------------------------------- Rearrange -------------------------------------
// Here is an example that rearranges a NEON vector with 4 ints:
// Rearrange V1 int[a0, a1, a2, a3] to V2 int[a2, a3, a0, a1]
//   1. Get the indices of V1 and store them as Vi byte[0, 1, 2, 3].
//   2. Convert Vi byte[0, 1, 2, 3] to the indices of V2 and also store them as Vi byte[2, 3, 0, 1].
//   3. Unsigned extend Long Vi from byte[2, 3, 0, 1] to int[2, 3, 0, 1].
//   4. Multiply Vi int[2, 3, 0, 1] with constant int[0x04040404, 0x04040404, 0x04040404, 0x04040404]
//      and get tbl base Vm int[0x08080808, 0x0c0c0c0c, 0x00000000, 0x04040404].
//   5. Add Vm with constant int[0x03020100, 0x03020100, 0x03020100, 0x03020100]
//      and get tbl index Vm int[0x0b0a0908, 0x0f0e0d0c, 0x03020100, 0x07060504]
//   6. Use Vm as index register, and use V1 as table register.
//      Then get V2 as the result by tbl NEON instructions.
// Notes:
//   Step 1 matches VectorLoadConst.
//   Step 3 matches VectorLoadShuffle.
//   Step 4, 5, 6 match VectorRearrange.
//   For VectorRearrange short/int, the reason why such complex calculation is
//   required is because NEON tbl supports bytes table only, so for short/int, we
//   need to lookup 2/4 bytes as a group. For VectorRearrange long, we use bsl
//   to implement rearrange.
define(`VECTOR_REARRANGE_B', `
instruct rearrange$1B`'(vec$2 dst, vec$2 src, vec$2 shuffle)
%{
  predicate(n->as_Vector()->length() == $1 &&
            n->bottom_type()->is_vect()->element_basic_type() == T_BYTE);
  match(Set dst (VectorRearrange src shuffle));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst);
  format %{ "tbl $dst, {$dst}, $shuffle\t# rearrange $1B" %}
  ins_encode %{
    __ tbl(as_FloatRegister($dst$$reg), __ T$1B,
           as_FloatRegister($src$$reg), 1, as_FloatRegister($shuffle$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1  $2
VECTOR_REARRANGE_B(8,  D)
VECTOR_REARRANGE_B(16, X)
dnl
define(`VECTOR_REARRANGE_S', `
instruct rearrange$1S`'(vec$2 dst, vec$2 src, vec$2 shuffle, vec$2 tmp0, vec$2 tmp1)
%{
  predicate(n->as_Vector()->length() == $1 &&
            n->bottom_type()->is_vect()->element_basic_type() == T_SHORT);
  match(Set dst (VectorRearrange src shuffle));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp0, TEMP tmp1);
  format %{ "mov   $tmp0, CONSTANT\t# constant 0x0202020202020202\n\t"
            "mov   $tmp1, CONSTANT\t# constant 0x0100010001000100\n\t"
            "mulv  $dst, T$1H, $shuffle, $tmp0\n\t"
            "addv  $dst, T$3B, $dst, $tmp1\n\t"
            "tbl   $dst, {$src}, $dst\t# rearrange $1S" %}
  ins_encode %{
    __ mov(as_FloatRegister($tmp0$$reg), __ T$3B, 0x02);
    __ mov(as_FloatRegister($tmp1$$reg), __ T$1H, 0x0100);
    __ mulv(as_FloatRegister($dst$$reg), __ T$1H,
            as_FloatRegister($shuffle$$reg), as_FloatRegister($tmp0$$reg));
    __ addv(as_FloatRegister($dst$$reg), __ T$3B,
            as_FloatRegister($dst$$reg), as_FloatRegister($tmp1$$reg));
    __ tbl(as_FloatRegister($dst$$reg), __ T$3B,
           as_FloatRegister($src$$reg), 1, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl                $1 $2 $3
VECTOR_REARRANGE_S(4, D, 8)
VECTOR_REARRANGE_S(8, X, 16)

instruct rearrange4I(vecX dst, vecX src, vecX shuffle, vecX tmp0, vecX tmp1)
%{
  predicate(n->as_Vector()->length() == 4 &&
           (n->bottom_type()->is_vect()->element_basic_type() == T_INT ||
            n->bottom_type()->is_vect()->element_basic_type() == T_FLOAT));
  match(Set dst (VectorRearrange src shuffle));
  ins_cost(INSN_COST);
  effect(TEMP_DEF dst, TEMP tmp0, TEMP tmp1);
  format %{ "mov   $tmp0, CONSTANT\t# constant 0x0404040404040404\n\t"
            "mov   $tmp1, CONSTANT\t# constant 0x0302010003020100\n\t"
            "mulv  $dst, T8H, $shuffle, $tmp0\n\t"
            "addv  $dst, T16B, $dst, $tmp1\n\t"
            "tbl   $dst, {$src}, $dst\t# rearrange 4I" %}
  ins_encode %{
    __ mov(as_FloatRegister($tmp0$$reg), __ T16B, 0x04);
    __ mov(as_FloatRegister($tmp1$$reg), __ T4S, 0x03020100);
    __ mulv(as_FloatRegister($dst$$reg), __ T4S,
            as_FloatRegister($shuffle$$reg), as_FloatRegister($tmp0$$reg));
    __ addv(as_FloatRegister($dst$$reg), __ T16B,
            as_FloatRegister($dst$$reg), as_FloatRegister($tmp1$$reg));
    __ tbl(as_FloatRegister($dst$$reg), __ T16B,
           as_FloatRegister($src$$reg), 1, as_FloatRegister($dst$$reg));
  %}
  ins_pipe(pipe_slow);
%}

//-------------------------------- Anytrue/alltrue -----------------------------
dnl
define(`ANYTRUE_IN_MASK', `
instruct anytrue_in_mask$1B`'(iRegINoSp dst, vec$2 src1, vec$2 src2, vec$2 tmp, rFlagsReg cr)
%{
  predicate(static_cast<const VectorTestNode*>(n)->get_predicate() == BoolTest::ne);
  match(Set dst (VectorTest src1 src2 ));
  ins_cost(INSN_COST);
  effect(TEMP tmp, KILL cr);
  format %{ "addv  $tmp, T$1B, $src1\t# src1 and src2 are the same\n\t"
            "umov  $dst, $tmp, B, 0\n\t"
            "cmp   $dst, 0\n\t"
            "cset  $dst" %}
  ins_encode %{
    __ addv(as_FloatRegister($tmp$$reg), __ T$1B, as_FloatRegister($src1$$reg));
    __ umov($dst$$Register, as_FloatRegister($tmp$$reg), __ B, 0);
    __ cmpw($dst$$Register, zr);
    __ csetw($dst$$Register, Assembler::NE);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1  $2
ANYTRUE_IN_MASK(8,  D)
ANYTRUE_IN_MASK(16, X)
dnl
define(`ALLTRUE_IN_MASK', `
instruct alltrue_in_mask$1B`'(iRegINoSp dst, vec$2 src1, vec$2 src2, vec$2 tmp, rFlagsReg cr)
%{
  predicate(static_cast<const VectorTestNode*>(n)->get_predicate() == BoolTest::overflow);
  match(Set dst (VectorTest src1 src2 ));
  ins_cost(INSN_COST);
  effect(TEMP tmp, KILL cr);
  format %{ "andr  $tmp, T$1B, $src1, $src2\t# src2 is maskAllTrue\n\t"
            "notr  $tmp, T$1B, $tmp\n\t"
            "addv  $tmp, T$1B, $tmp\n\t"
            "umov  $dst, $tmp, B, 0\n\t"
            "cmp   $dst, 0\n\t"
            "cset  $dst" %}
  ins_encode %{
    __ andr(as_FloatRegister($tmp$$reg), __ T$1B,
            as_FloatRegister($src1$$reg), as_FloatRegister($src2$$reg));
    __ notr(as_FloatRegister($tmp$$reg), __ T$1B, as_FloatRegister($tmp$$reg));
    __ addv(as_FloatRegister($tmp$$reg), __ T$1B, as_FloatRegister($tmp$$reg));
    __ umov($dst$$Register, as_FloatRegister($tmp$$reg), __ B, 0);
    __ cmpw($dst$$Register, zr);
    __ csetw($dst$$Register, Assembler::EQ);
  %}
  ins_pipe(pipe_slow);
%}')dnl
dnl             $1  $2
ALLTRUE_IN_MASK(8,  D)
ALLTRUE_IN_MASK(16, X)
dnl
// END This section of the file is automatically generated. Do not edit --------------
