a = 7;
b = 5;

a = a - 2;
b = b + 5;
C = (a ** 2 + b ** 2) ** 0.5
print(f"The length of the hypotenuse is: {C}")

D = int(C // 3);
print(f"The length of the segment is: {D}")

E = int(D % 2);
print(f"The remainder is: {E}")
