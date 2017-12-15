/*
 * Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have
 * questions.
 */
package com.oracle.vector.el.expression.bexp;

import com.oracle.vector.el.Ops;
import com.oracle.vector.el.Shape;
import com.oracle.vector.el.expression.Expression;
import com.oracle.vector.el.expression.VConst;
import com.oracle.vector.el.visitor.ExpressionEvaluator;

import java.util.Optional;

public class VBinBExp<E,S extends Shape> extends BOpExp<S> {

    private final Expression<E,S> left;
    private final Expression<E,S> right;

    public VBinBExp(Expression<E,S> left, Expression<E,S> right, Ops op) {
       super(op,left.elementType(),left.shape());
       this.left  = left;
       this.right = right;
    }

    public Expression<E,S> getLeft() {
        return left;
    }

    public Expression<E,S> getRight() {
        return right;
    }

    @Override
    public <R> R accept(ExpressionEvaluator<R> v) {
        return v.visit(this);
    }

    @Override
    public int length() {
        return this.shape.length();
    }

    @Override
    public Class<Boolean> elementType() {
        return Boolean.class;
    }

    public Class<E> getRealElementType() { return left.elementType(); }

    @Override
    public Optional<VConst<Boolean, S>> toVConst() {
        return Optional.empty();
    }


}
