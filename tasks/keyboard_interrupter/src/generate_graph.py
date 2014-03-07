import random
import sys

VERTICES_COUNT = 50
EDGES_COUNT = 10
LAST = 5

def split(xs):
  random.shuffle(xs)
  return (xs[:len(xs) // 2], xs[len(xs) // 2:])

def print_dot(edges_list):
  print("digraph G {")
  for v, edges in edges_list.items():
    for e in edges:
      print("v%d -> v%d;" % (v, e))
  print("}")

def print_asm(edges_list):
  for v in sorted(edges_list.keys()):
    edges = edges_list[v]
    random.shuffle(edges)
    print("        db", ", ".join(['0%02Xh' % x for x in edges]))
  

def path_count(edges_list, start, finish, length):
  if length == 1:
    return 1 if finish in edges_list[start] else 0
  result = 0
  for e in edges_list[start]:
    result += path_count(edges_list, e, finish, length - 1)
  return result

def beautify(edges_list, part):
  validated = path_count(edges_list, part[0], part[-1], LAST)
  assert(validated == 1)
  commited = 0
  while commited < EDGES_COUNT * 2:
    v = random.choice(part)
    e = random.choice(edges_list[v])
    if e not in part:
      continue
    new_e = random.choice(part[-LAST:])
    if new_e in edges_list[v] or new_e == v:
      continue
    edges_list[v].append(new_e)
    validated = path_count(edges_list, part[0], part[-1], LAST)
    if validated != 1:
      edges_list[v].remove(new_e) # rollback
    else:
      edges_list[v].remove(e)     # commit
      commited += 1



part1, part2 = split(list(range(VERTICES_COUNT)))
start = part1[0]
finish = part2[0]
out1 = part1[-1]
in2 = part2[-1]

edges_list = {}
for v in range(VERTICES_COUNT):
  edges_list[v] = []
  for e in range(EDGES_COUNT):
    other = v
    while (other == v) or (other in edges_list[v]) or (v in part1 and other not in part1) or (v in part2 and other not in part2) or \
      (other in part1[-LAST:]) or (other in part2[-LAST:]):
      other = random.randint(0, VERTICES_COUNT - 1)
    edges_list[v].append(other)

path = [start] + part1[-LAST:] + [part2[0]] + part2[-LAST:]
for idx, p in enumerate(path[:-1]):
  edges_list[p].remove(random.choice(edges_list[p]))
  edges_list[p].append(path[idx + 1])

beautify(edges_list, part1)
beautify(edges_list, part2)

print("Check. Must be %d:" % EDGES_COUNT, min([len(x) for x in edges_list.values()]), file=sys.stderr)
assert(EDGES_COUNT == min([len(x) for x in edges_list.values()]))
print("Check. Must be %d:" % EDGES_COUNT, max([len(x) for x in edges_list.values()]), file=sys.stderr)
assert(EDGES_COUNT == max([len(x) for x in edges_list.values()]))

print_asm(edges_list)

print("Check. Must be 1:", path_count(edges_list, part1[0], part1[-1], LAST) * path_count(edges_list, part2[0], part2[-1], LAST), file=sys.stderr)
assert(1 == path_count(edges_list, part1[0], part1[-1], LAST) * path_count(edges_list, part2[0], part2[-1], LAST))
print("Path is", path, file=sys.stderr)


