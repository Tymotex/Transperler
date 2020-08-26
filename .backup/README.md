# Sheeple Transpiler
A transpiler that maps POSIX-compatible shell scripts to a Perl 5 equivalent. Aims to preserve comments and indentation. 

### Example Usage:
Cloning this repo: `git clone https://github.com/Tymotex/Sheeple && cd Sheeple`
Converting scripts: `sheeple <shell script>`

Eg. `sheeple examples/primes.sh`

![Primes.sh](./images/PrimesSh.png "Primes.sh")
![Primes.pl](./images/PrimesPl.png "Primes.pl")

Eg. `sheeple examples/series.sh`

![Series.sh](./images/SeriesSh.png "Series.sh")
![Series.pl](./images/SeriesPl.png "Series.pl")
