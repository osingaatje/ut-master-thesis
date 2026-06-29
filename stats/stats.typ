// calculate s^2 for a given population (array of int/float)
#let estimate_variance(s: ()) = {
  // based on https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance -> Two-pass algorithm
  let n = s.len()
  let mean = s.sum() / n

  return s.fold(0, (sum, elem) => { sum + calc.pow(elem - mean, 2)}) / (n - 1)
}

// takes in two-column data, performs mann-whitney on it. Inspired from https://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
#let mann_whitney_utest(s: ((), ())) = {
  if s.len() < 1 or s.at(0).len() != 2 {
    panic("Mann-whitney must be given a two-column dataset")
  }

  // join all samples into one big array
  let all_samples = s.flatten().sorted()
  let groups = (s.map(e => e.at(0)), s.map(e => e.at(1)))
  let n1 = groups.at(0).len()
  let n2 = groups.at(1).len()

  // first assume unranked (i.e. (1,2,3,4,5,6,7,8) (..but the 'ranks' has 0..7)
  let ranks = all_samples.enumerate()
  let rank-dict = ranks.map(r => {
    let i = r.at(0)
    let e = r.at(1)
    let e_str = str(e)

    if i == 0 {
      return (e_str, i+1)
    }
    let (prev-i, prev-e) = ranks.at(i - 1)
    if prev-e == e {
      return (e_str, prev-i+1)
    } else {
      return (e_str, i+1)
    }
  }).to-dict()

  let group-ranks = ( groups.at(0).map(e => rank-dict.at(str(e))), groups.at(1).map(e => rank-dict.at(str(e))) )
  let group-sums = ( group-ranks.at(0).sum(), group-ranks.at(1).sum() )

  let (u1,u2) = (group-sums.at(0) - (n1*(n1+1))/2, group-sums.at(1) - (n2*(n2+1))/2)
  let U = calc.min(u1,u2)
  
  let mU = ( n1 * n2 ) / 2
  // TODO account for ties by counting number of ties etc. - see Wiki
  let sU /* accounts for ties */ = calc.sqrt( ( n1 * n2 * ( n1 + n2 + 1 ) ) / 12 ) // = calc.sqrt( ( n1 * n2 ) / 12 * ( (n+1) - (  ) ))

  let z = (U - mU) / sU // z-value
  let p = (1 / calc.sqrt(2 * calc.pi)) * calc.pow(calc.e, (-1 * calc.pow(z,2)) / 2)  // estimated chance, assuming two-tail

  return (U: U, z: z, p: p)
}
