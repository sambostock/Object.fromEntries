const Benchmark = require('benchmark')

const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
function makeid() {
  let text = "";
  for (let i = 0; i < 5; i++) text += possible.charAt(Math.floor(Math.random() * possible.length));
  return text;
}

function generatePairs(n) {
  const pairs = []
  for(let i = 0; i < n; i++) pairs.push([makeid(), makeid()])
  return pairs
}

function withObjectAssign(object, [key, value]) { return Object.assign(object, {[key]: value}) }
function withSpread(object, [key, value]) { return {...object, [key]: value} }
 
function benchmark(n) {
  console.log('Generating ' + n + ' pairs');
  const pairs = generatePairs(n);
  console.log('Benchmarking...');
  new Benchmark.Suite()
    .add('Array#reduce with Object.assign', function() {
      pairs.reduce(withObjectAssign, {})
    })

    .add('Array#reduce with spread', function() {
      pairs.reduce(withSpread, {})
    })

    .on('cycle', function(event) {
      console.log(String(event.target));
    })

    .on('complete', function() {
      console.log('Fastest is ' + this.filter('fastest').map('name'));
    })

    .run({ 'async': false });
  console.log();
}

for(let i = 1; i <= 2**16; i = i * 2) benchmark(i)
