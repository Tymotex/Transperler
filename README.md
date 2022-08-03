# Transperler
A transpiler written in Perl 5 that maps POSIX shell scripts to equivalent Perl 5 scripts. Supports most of the control structures and builtin commands in the POSIX Shell standard. Aims to preserve comments and indentation in the Shell source code.

### Example Usage:
`transperler <shell script>`

Eg. `./transperler examples/primes.sh`

![Primes.sh](./images/PrimesSh.png "Primes.sh")
![Primes.pl](./images/PrimesPl.png "Primes.pl")

Eg. `./transperler examples/series.sh`

![Series.sh](./images/SeriesSh.png "Series.sh")
![Series.pl](./images/SeriesPl.png "Series.pl")
