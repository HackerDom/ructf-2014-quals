plaintext = open('plaintext').read()

plaintext = ''.join([ch.lower() for ch in plaintext if ch.isalpha() or ch == ' '])

word_subs = {
        "and": 0,
        "for": 0,
        "with": 0,
        "that": 0,
        "if": 0,
        "but": 0,
        "where": 0,
        "as": 0,
        "of": 0,
        "the": 0,
        "from": 0,
        "by": 0,
        "so": 0,
        "not": 0,
        "when": 0,
        "there": 0,
        "this": 0,
        "in": 0,
        "is": 0,
        "what": 0,
        "my": 0,
        "me": 0,
        }

nules = [
            
        ]

print(len(plaintext))
for word in plaintext.split():
    if word in word_subs:
        word_subs[word] += 1
