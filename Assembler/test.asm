@text
@data
float: x #488.826
float: y #125.34
float: z #0.75
float: a #0.50
int: b #7
int: c #2
@func
and $f0, $f0, #0
and $f1, $f1, #0
ldf $f0, x
ldf $f1, y
add $f2, $f0, $f1
out $f2
pause
divf $f0, $f1
mvlo $f2
out $f2
pause
rnd $i0, $f0
out $i0
pause
ldf $f0, z
ldf $f1, a
cmpf $f0, $f1
ifp #1
pause
ld $i0, b
ld $i1, c
div $i0, $i1
mvhi $i2
out $i2
pause
@end
