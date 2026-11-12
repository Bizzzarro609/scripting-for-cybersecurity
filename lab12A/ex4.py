sentence = input("Enter a string: ");

reverse_sentence = "".join(reversed(sentence));

if sentence == reverse_sentence:
    print(sentence + " is palindrome ");
else:
    print(sentence + " is not palindrome");