# Princip of the algorithm.

1. Parse the user commands file to obtain a list of changes that we have to apply.
2. Parse the CSV file to obtain a list of changes associated to the formulae of the file.
3. Compute the initial value of each changes (the initial value is the value of the cell if we only consider the initial values of the file, that is to say we do not consider the formulae).
4. Evaluate the initial list of changes.
5. For each user command changes, add the change to the list of already applied changes and re-evaluate the changes.

To evaluate a list of changes, we just have to compute for each change the set of changes that it affects (`a` affects `b` if and only if `b` is a change of type B and the block in which it counts contained the position of `a`). In other words, it consists to compute the dependencies. Then for each change, we juste have to propagate its value to its dependencies recursively. If in the recursive calls, we reach a change `c` that we have already seen, then it means that there is a cycle. When it arrives, it means that `c` gives an incorrect value, and then all the change affecteds by `c` are also incorrect and we propagate the error recursively.

# Organization

Hence, there are one principal class `Change` which represent a change (a value, a positiion, its old value (to know if the value changed, a flag to know if this change gives a correct value, and the list of changes that it affects). This class is extended by `AChange` and `BChange`, which represents respectively a change of type A and a change of type B. There is also an object `Change` containing some usefull methods on changes, a class `Position`, and a class `Block`.

And we have the following objects to that.

- `CellParser` to parse a cell and obtain a change,
- `UserFileParser` to parse a file with user commands and obtain the changes associated to,
- `CSVParser` to parse a CSV file and obtain the changes associated to its formulae,
- `CSVPreProcessor` to compute the initial value of the changes.
- `Dependencies` to compute the dependencies of a list of changes.
- `Evaluator` to evaluate a list of changes.
- `Modifier` to apply a new change (given a list of already applied changes).

We also have printer objects, `CommandEffectsPrinter` and `CSVPrinter`, and reource management object (to close automatically the resource), `Reader` and `Writer`.
