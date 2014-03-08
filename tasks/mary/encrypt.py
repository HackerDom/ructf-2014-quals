import sys
import random

plaintext = open('p').read()

# cipher_symbols = [u'\u4e66', u'\u4e21', u'\u4e4c', u'\u4eff', u'\u4e90', u'\u4e11', u'\u4e63', u'\u4e08', u'\u4edc', u'\u4e5e', u'\u4e28', u'\u4e8b', u'\u4e54', u'\u4e4e', u'\u4e7f', u'\u4e20', u'\u4e7b', u'\u4ef9', u'\u4ec1', u'\u4e65', u'\u4e57', u'\u4ecc', u'\u4e4a', u'\u4e19', u'\u4eb4', u'\u4ede', u'\u4e22', u'\u4ee8', u'\u4e67', u'\u4e50', u'\u4e24', u'\u4eea', u'\u4e07', u'\u4e5a', u'\u4e64', u'\u4e9e', u'\u4ebf', u'\u4e37', u'\u4e88', u'\u4ee7', u'\u4e86', u'\u4e16', u'\u4e42', u'\u4e7c', u'\u4ed9', u'\u4e5d', u'\u4ec6', u'\u4e10', u'\u4e80', u'\u4e48', u'\u4e23', u'\u4e6c', u'\u4ebc', u'\u4ea2', u'\u4ee5', u'\u4eaa', u'\u4e49', u'\u4eae', u'\u4e73', u'\u4e83', u'\u4e61', u'\u4e2f', u'\u4e7a', u'\u4e95', u'\u4e9a', u'\u4e47', u'\u4e7d', u'\u4e27', u'\u4e3a', u'\u4ec0', u'\u4ecb', u'\u4e15', u'\u4eed', u'\u4e98', u'\u4e40', u'\u4e5f', u'\u4e97', u'\u4e9f', u'\u4e39', u'\u4e4b', u'\u4e4f', u'\u4e8a', u'\u4eec', u'\u4e6a', u'\u4e71', u'\u4e35', u'\u4e1f', u'\u4e29', u'\u4e52', u'\u4ec2', u'\u4ee9', u'\u4ed6', u'\u4ea0', u'\u4e5b', u'\u4e59', u'\u4eb6', u'\u4ea8', u'\u4efc', u'\u4e2a', u'\u4e8f', u'\u4e4d', u'\u4e04', u'\u4e89', u'\u4e12', u'\u4e0c', u'\u4ef1', u'\u4e96', u'\u4e06', u'\u4e60', u'\u4e5c', u'\u4e25', u'\u4ee2', u'\u4e85', u'\u4ef2', u'\u4ea1', u'\u4ee0', u'\u4eba', u'\u4ef5', u'\u4e8c', u'\u4e7e', u'\u4ea4', u'\u4e2c', u'\u4e41', u'\u4ed0', u'\u4ef3', u'\u4ed8', u'\u4efd', u'\u4ed2', u'\u4eb2', u'\u4ea6', u'\u4ea3', u'\u4e1c', u'\u4ed5', u'\u4e32', u'\u4e3f', u'\u4e44', u'\u4e1d', u'\u4eb0', u'\u4e2d', u'\u4e30', u'\u4e2e', u'\u4e70', u'\u4ece', u'\u4e18', u'\u4ecf', u'\u4eaf', u'\u4e26', u'\u4e92', u'\u4edb', u'\u4e2b', u'\u4e72', u'\u4eb8', u'\u4e81', u'\u4e94', u'\u4e38', u'\u4ec3', u'\u4e75', u'\u4eef', u'\u4ed1', u'\u4ea9', u'\u4e6e', u'\u4e69', u'\u4e6b', u'\u4ee4', u'\u4ecd', u'\u4ea5', u'\u4e05', u'\u4ef4', u'\u4ef6', u'\u4e6d', u'\u4e84', u'\u4efa', u'\u4e03', u'\u4e77', u'\u4e9d', u'\u4eab', u'\u4e0a', u'\u4e58', u'\u4e31', u'\u4ee1', u'\u4ead', u'\u4e14', u'\u4e74', u'\u4ec9', u'\u4e1b', u'\u4ebb', u'\u4e36', u'\u4e51', u'\u4e3e', u'\u4efb', u'\u4eb3', u'\u4e8e', u'\u4ef7', u'\u4e02', u'\u4e78', u'\u4eb7', u'\u4e1e', u'\u4ec7', u'\u4eca', u'\u4ef0', u'\u4e3d', u'\u4e43', u'\u4e56', u'\u4e62', u'\u4ef8', u'\u4e76', u'\u4eb5', u'\u4edd', u'\u4ee6', u'\u4e0f', u'\u4eb1', u'\u4e6f', u'\u4eb9', u'\u4e0d', u'\u4e46', u'\u4ed7', u'\u4e00', u'\u4efe', u'\u4ed4', u'\u4ec4', u'\u4e55', u'\u4e9c', u'\u4e0b', u'\u4e9b', u'\u4ec8', u'\u4ee3', u'\u4ebd', u'\u4e79', u'\u4e87', u'\u4e82', u'\u4e8d', u'\u4e01', u'\u4ea7', u'\u4e0e', u'\u4eee', u'\u4e3b', u'\u4e3c', u'\u4e99', u'\u4e93', u'\u4e17', u'\u4e33', u'\u4e13', u'\u4ed3', u'\u4e68', u'\u4e91', u'\u4e34', u'\u4e53', u'\u4eda', u'\u4ec5', u'\u4e45', u'\u4ebe', u'\u4edf', u'\u4eeb', u'\u4eac', u'\u4e1a', u'\u4e09']

cipher_symbols = [chr(i + 0x4e00) for i in range(0, 256)]
random.shuffle(cipher_symbols)

word_subs = {
        "and": 0,
        "for": 1,
        "with": 2,
        "that": 3,
        "if": 4,
        "but": 5,
        "where": 6,
        "as": 7,
        "of": 8,
        "the": 9,
        "from": 10,
        "by": 11,
        "so": 12,
        "not": 13,
        "when": 14,
        "there": 15,
        "this": 16,
        "in": 17,
        "is": 18,
        "what": 19,
        "my": 20,
        "me": 21,
        }

nules = [
            22,
            23,
            24,
            25
        ]

back = 26

subs = {
        "a": 27,
        "b": 28,
        "c": 29,
        "d": 30,
        "e": 31,
        "f": 32,
        "g": 33,
        "h": 34,
        "i": 35,
        "j": 36,
        "k": 37,
        "l": 38,
        "m": 39,
        "n": 40,
        "o": 41,
        "p": 42,
        "q": 43,
        "r": 44,
        "s": 45,
        "t": 46,
        "u": 47,
        "v": 48,
        "w": 49,
        "x": 50,
        "y": 51,
        "z": 52
        }

for word in plaintext.split():
    if word in word_subs:
        if random.randint(0, 1000) < 10:
            sys.stdout.write(cipher_symbols[nules[random.randint(0, 3)]])
        elif random.randint(0, 1000) < 10:
            backs = random.randint(1, 5)
            for i in range(0, backs):
                sys.stdout.write(cipher_symbols[random.randint(27, 52)])
            for i in range(0, backs):
                sys.stdout.write(cipher_symbols[back])
        sys.stdout.write(cipher_symbols[word_subs[word]])
        if random.randint(0, 1000) < 10:
            sys.stdout.write(cipher_symbols[nules[random.randint(0, 3)]])
        elif random.randint(0, 1000) < 10:
            backs = random.randint(1, 5)
            for i in range(0, backs):
                sys.stdout.write(cipher_symbols[random.randint(27, 52)])
            for i in range(0, backs):
                sys.stdout.write(cipher_symbols[back])
    else:
        for c in word:
            sys.stdout.write(cipher_symbols[subs[c]])
            if random.randint(0, 1000) < 10:
                sys.stdout.write(cipher_symbols[nules[random.randint(0, 3)]])
            elif random.randint(0, 1000) < 10:
                backs = random.randint(1, 5)
                for i in range(0, backs):
                    sys.stdout.write(cipher_symbols[random.randint(27, 52)])
                for i in range(0, backs):
                    sys.stdout.write(cipher_symbols[back])
    sys.stdout.write(' ')
