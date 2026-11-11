charset = ['f', 'a', 'b', 'c', 'j', 'i', 'e', '*', ')', '£', '2', '/', 's', 'o']
i = 0;

for char in charset:
    if char == "e":
        print("Character 'e' is found");
        break

while i < len(charset):
    if charset[i] == "e":
        print("Character 'e' is found");
        break
    i += 1 

