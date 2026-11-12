a = []
n = int(input("Enter number of elements of the list to be created: "))

for i in range(n):
    num = int(input())
    a.append(num)

new_li = [a[0], a[-1]]

print(new_li)


