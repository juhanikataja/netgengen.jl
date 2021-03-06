module netgengen

abstract type CSGObject end
abstract type LineObject end
abstract type CurveObject <: LineObject end
abstract type CSGCompositeObject <: CSGObject end
abstract type CSGPrimitive <: CSGObject end

export torus, plane, CSGObject, brick, csgunion, csgstring, declare, not, cylinder, sphere, tlo, intersection, curve2d, LineObject, revolution, CurveObject

function ComposeModifiers(flags...)
  output = ""
  for flag in flags
    if(typeof(flag[2])==Bool)
      output = string(output, " -", string(flag[1]))
    else
      output = string(output, " -", string(flag[1]), "=", string(flag[2]))
    end
  end
  return output
end

"""
`function tlo(E::CSGObject, buf=STDOUT; flags...)`

Prints out netgen string of `E` to buffer `buf` and appends `flags` to the end of the string

"""
function tlo(E::CSGObject, buf=STDOUT; flags...)
  if !(E.declared)
    declare(E,buf)
  end
  print(buf, "tlo ", csgstring(E), ComposeModifiers(flags...), ";\n")
end

"""
`type not`

`not(E)` constructs complement of `E`

`not(name, E; modifiers...)` constructs complement of `E`, assigns it with String `name` and `modifiers...`
"""
type not <: CSGCompositeObject
  name::String
  E::Array{CSGObject,1}
  expr::String
  modifiers::String
  declared::Bool
  not(E) = (x = new();
    x.E = [E];
    x.expr = string("not ", csgstring(E));
    x.name = "";
    x.modifiers = "";
    x.declared = false;
    return x)
  not(name, E; modifiers...) = (x = not(E); x.name=name; x.modifiers = ComposeModifiers(modifiers...); return x)
end

"""
`type torus`

`torus(p,q,m,n)` constructs torus from length 3 vectors `p`,`q` and scalars `m` and `n` where

* `p` is the center of the torus
* `q` is the normal vector to the torus
* `m` is the distance from center to the center of the torus ring
* `n` is the radius of the torus ring

`torus(name,p,q,m,n;modifiers...)` same as above but assigns it with `name` and `modifiers...`
"""
type torus <: CSGObject
  name::String
  p::Array{AbstractFloat, 1}
  q::Array{AbstractFloat, 1}
  m::AbstractFloat
  n::AbstractFloat
  expr::String
  modifiers::String
  declared::Bool
  torus(p,q,m,n) = (
    x = new();
    x.p = p;
    x.q = q;
    x.m = m;
    x.n = n;
    x.expr = string("torus ($(x.p[1]), $(x.p[2]), $(x.p[3]); $(x.q[1]), $(x.q[2]), $(x.q[3]); $(x.m); $(x.n))");
    x.modifiers = "";
    x.declared = false;
    x.name = "";
    return x)
  torus(name, p, q, m,n; modifiers...) = (
    x = (torus(p,q,m,n));
    x.name = name;
    x.modifiers= ComposeModifiers(modifiers...);
    return x)
end

"""
`type cylinder`

`cylinder(p,q,r)` constructs cylinder where

* `p` and `q` are length 3 vectors for endpoints of the cylinder and `r` is the radius of the cylinder

`cylinder(name,p,q,r;modifiers...)`

* same as above but adds `name` and `modifiers...`
"""
type cylinder <: CSGObject
  name::String
  p::Array{AbstractFloat, 1}
  q::Array{AbstractFloat, 1}
  r::AbstractFloat
  expr::String
  modifiers::String
  declared::Bool
  cylinder(p,q,r) = (
    x = new();
    x.p = p;
    x.q = q;
    x.r = r;
    x.expr = string("cylinder ($(x.p[1]), $(x.p[2]), $(x.p[3]); $(x.q[1]), $(x.q[2]), $(x.q[3]); $(x.r))");
    x.modifiers = "";
    x.declared = false;
    x.name = "";
    return x)
  cylinder(name, p, q, r; modifiers...) = (
    x = cylinder(p,q,r);
    x.name = name;
    x.modifiers= ComposeModifiers(modifiers...);
    return x)
end

"""
`type plane`

`plane(p,n)` constructs half space where

* `p` is a point on its boundary and
* `n` outside normal vector to the plane
"""
type plane <: CSGObject
  name::String
  p::Array{AbstractFloat, 1}
  n::Array{AbstractFloat, 1}
  expr::String
  modifiers::String
  declared::Bool
  plane(p,n;modifiers...) = (
    x = new();
    x.p = p;
    x.n = n;
    x.expr = string("plane ($(x.p[1]), $(x.p[2]),$(x.p[3]); $(x.n[1]), $(x.n[2]), $(x.n[3]))");
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    x.name = "";
    return x)
  plane(name::String, p, n; modifiers...) = (
    x = plane(p,n);
    x.name=name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

"""
`type brick`

`brick(p,q)` constructs 3D interval where with coordinate minima in vector `p` and maxima in `q`
"""
type brick <: CSGObject
  name::String
  p::Array{AbstractFloat, 1}
  q::Array{AbstractFloat, 1}
  expr::String
  modifiers::String
  declared::Bool
  brick(p,q) = (
    x = new();
    x.p = p;
    x.q = q;
    x.expr = string("orthobrick ($(x.p[1]), $(x.p[2]), $(x.p[3]); $(x.q[1]), $(x.q[2]), $(x.q[3]))");
    x.modifiers = "";
    x.declared = false;
    x.name = "";
    return x)
  brick(name::String, p, q; modifiers...) = (
    x = brick(p,q);
    x.name = name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

type curve3d <: CurveObject
  name::String
  np::Integer
  ns::Integer
  p::Array{Float64, 2}
  t::Array{Array{Integer,1},1}
  expr::String
  modifiers::String
  declared::Bool
  curve3d(name, p,t) = (
    x = new();
    x.p = p;
    x.t = t;
    x.np = size(p,2);
    x.ns = length(t);
    x.name = name;
    evalexpr(x);
    return x;
    )
end

type curve2d <: CurveObject
  name::String
  np::Integer
  ns::Integer
  p::Array{Float64, 2}
  t::Array{Array{Integer,1},1}
  expr::String
  modifiers::String
  declared::Bool
  curve2d(name, p,t) = (
    x = new();
    x.p = p;
    x.t = t;
    x.np = size(p,2);
    x.ns = size(t,1);
    x.name = name;
    x.expr = evalexpr(x);
    return x;
    )
end

function evalexpr(x::curve2d)
  expr = string("curve2d $(x.name) = ($(x.np);"); 
  for k = 1:x.np
    expr = string(expr, "\n\t\t$(x.p[1,k]), $(x.p[2,k]);")
  end
  expr = string(expr, "\n\t\t$(x.ns);")
  for k = 1:length(x.t)-1
    if length(x.t[k]) == 2
      expr = string(expr, "\n\t\t2, $(x.t[k][1]), $(x.t[k][2]);")
    elseif length(x.t[k]) == 3
      expr = string(expr, "\n\t\t3, $(x.t[k][1]), $(x.t[k][2]), $(x.t[k][3]);")
    else
      error("Wrong size of segment $(x.t[k])")
    end
  end
  seg = x.t[end]
  if length(seg) == 2
    expr = string(expr, "\n\t\t2, $(seg[1]), $(seg[2])")
  elseif length(seg) == 3
    expr = string(expr, "\n\t\t3, $(seg[1]), $(seg[2]), $(seg[3])")
  else
    error("Wrong size of segment $(seg)")
  end
  expr = string(expr, ");\n")
  return expr
end

function evalexpr(x::curve3d)
  expr = string("curve3d $(x.name) = ($(x.np),"); 
  for k = 1:x.np
    expr = string(expr, "\n\t\t$(x.p[1,k]), $(x.p[2,k]), $(x.p[3,k]);")
  end
  expr = string(expr, "\n\t\t$(x.ns);")
  for k = 1:length(x.t)-1
    if length(x.t[k]) == 2
      expr = string(expr, "\n\t\t2, $(x.t[k][1]), $(x.t[k][2]);")
    elseif length(x.t[k]) == 3
      expr = string(expr, "\n\t\t3, $(x.t[k][1]), $(x.t[k][2]), $(x.t[k][3]);")
    else
      error("Wrong size of segment $(x.t[k])")
    end
  end
  seg = x.t[end]
  if length(seg) == 2
    expr = string(expr, "\n\t\t2, $(seg[1]), $(seg[2])")
  elseif length(seg) == 3
    expr = string(expr, "\n\t\t3, $(seg[1]), $(seg[2]), $(seg[3])")
  else
    error("Wrong size of segment $(seg)")
  end
  expr = string(expr, ");\n")
  return expr
end

function MakeExpression!{T}(object::T)
  error("Not done!")
end

"""
`type sphere`

`sphere(c,R)` construct sphere with center `c` and radius `R`
"""
type sphere <: CSGObject
  name::String
  c::Array{AbstractFloat, 1}
  R::AbstractFloat
  expr::String
  modifiers::String
  declared::Bool
  sphere(c,R) = (
    x = new();
    x.c = c;
    x.R = R;
    x.expr = string("sphere ($(x.c[1]), $(x.c[2]), $(x.c[3]); $(R))");
    x.modifiers = "";
    x.declared = false;
    x.name = "";
    return x)
  sphere(name, c, R; modifiers...) = (
    x = (sphere(c,R));
    x.name = name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

type revolution <: CSGObject
  name::String
  p1::Array{AbstractFloat,1}
  p2::Array{AbstractFloat,1}
  curvename::String
  expr::String
  modifiers::String
  declared::Bool
  revolution(p1,p2,curvename) = (
    x = new();
    x.p1 = p1;
    x.p2 = p2;
    x.expr = string("revolution ($(x.p1[1]), $(x.p1[2]), $(x.p1[3]); $(x.p2[1]), $(x.p2[2]), $(x.p2[3]); $(curvename))");
    x.modifiers = "";
    x.declared = false;
    x.name = "";
    return x)
  revolution(name, p1, p2, curvename; modifiers...) = (
    x = (revolution(p1, p2, curvename));
    x.name = name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

"""
`type csgunion`

`csgunion(E)` constructs union of objects in array `E`

`csgunion(name,E,modifiers...)` constructs union of objects in array `E` and assigns it with `name` and `modifiers...`
"""
type csgunion <: CSGCompositeObject
  name::String
  E::Array{CSGObject,1}
  expr::String
  modifiers::String
  declared::Bool
  csgunion(E) = (
    x = new();
    x.E = E;
    x.expr = evalexpr(x);
    x.name = "";
    x.modifiers = "";
    x.declared = false;
    return x)
  csgunion(name, E; modifiers...) = (
    x = csgunion(E);
    x.name = name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

"""
`type intersection`

`intersection(E)` constructs intersection of objects in array `E`
`intersection(name,E,modifiers...)` constructs intersection of objects in array `E` and assigns it with `name` and `modifiers...`
"""
type intersection <: CSGCompositeObject
  name::String
  E::Array{CSGObject,1}
  expr::String
  modifiers::String
  declared::Bool
  intersection(E) = (
    x = new();
    x.E = E;
    x.expr = evalexpr(x);
    x.name = "";
    x.modifiers = "";
    x.declared = false;
    return x)
  intersection(name, E; modifiers...) = (
    x = intersection(E);
    x.name = name;
    x.modifiers = ComposeModifiers(modifiers...);
    x.declared = false;
    return x)
end

function csgstring(A::CSGObject)
  return A.name == "" ? A.expr : A.name;
end

function declare(A::CSGCompositeObject, buf=STDOUT)
  for sub_obj in A.E
    if(!sub_obj.declared) 
      declare(sub_obj, buf)
    end
  end
  A.declared = true
  if A.name == ""
    return true
  end
  println(buf, "solid ", A.name, " = ", A.expr, A.modifiers, ";")
  return true
end

function declare(A::CSGPrimitive, buf=STDOUT)
  if(!(A.declared))
    A.declared = true
  else
    return true
  end
  if A.name == ""
    return true
  end
  println(buf, "solid ", A.name, " = ", A.expr, A.modifiers, ";")
  return true
end

function declare(A::CSGObject, buf=STDOUT)
  if(!(A.declared))
    A.declared = true
  else
    return true
  end
  if A.name == ""
    return true
  end
  println(buf, "solid ", A.name, " = ", A.expr, A.modifiers, ";")
  return true
end

function declare(A::CurveObject, buf=STDOUT)
  println("warning: declare(A::CurveObject) might not do what wanted")
  return A.expr;
end

function evalexpr(A::csgunion)
  S = ""
  for m = 1:length(A.E)-1
    S = string(S, csgstring(A.E[m]), " or\n\t")
  end
  S = string(S, csgstring(A.E[length(A.E)]))
end

function evalexpr(A::intersection)
  S = ""
  for m = 1:length(A.E)-1
    S = string(S, csgstring(A.E[m]), " and\n\t")
  end
  S = string(S, csgstring(A.E[length(A.E)]))
end

# Utility functions
function finitecylinder(name, p,q,r; modifiers...)
  return intersection(name, [
      cylinder(p,q,r), 
      plane(p,p-q; bc=a),
      plane(q,q-p; bc=b)]; modifiers...)
end 

function finitecylinder(name, p,q,r, a, b; modifiers...)
  plane_a = plane(string(name, "_", a), p,p-q; bc=a)
  plane_b = plane(string(name, "_", b), q,q-p; bc=b)
  return intersection(name, [
      cylinder(p,q,r), 
      plane_a, plane_b]; modifiers...)
end 

end 
