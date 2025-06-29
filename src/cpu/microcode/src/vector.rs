use std::{
    fmt::Debug,
    ops::{Index, IndexMut},
};

#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Value {
    Zero,
    One,
    X,
}

#[derive(Clone)]
pub struct Vector {
    pub d: Vec<Value>,
}

impl Vector {
    pub fn with_size(size: usize) -> Vector {
        Vector {
            d: vec![Value::X; size],
        }
    }

    pub fn from_number(n: u64, size: usize) -> Vector {
        let mut v = Vector::with_size(size);

        for i in 0..size {
            v.d[i] = if n & (1 << i) != 0 {
                Value::One
            } else {
                Value::Zero
            }
        }

        return v;
    }

    pub fn from_str(s: &str) -> Vector {
        let d = s
            .chars()
            .rev()
            .filter_map(|c| match c {
                '0' => Some(Value::Zero),
                '1' => Some(Value::One),
                'X' => Some(Value::X),
                'x' => Some(Value::X),
                _ => None,
            })
            .collect::<Vec<_>>();

        Vector { d }
    }

    pub fn set_all(&mut self, val: Value) {
        self.d.iter_mut().for_each(|v| *v = val);
    }

    pub fn variate(&self) -> Vec<Vector> {
        let mut v = Vec::new();
        v.push(self.clone());

        for i in 0..self.d.len() {
            if self.d[i] == Value::X {
                let mut av = Vec::with_capacity(v.len());

                for sv in v.iter_mut() {
                    sv.d[i] = Value::Zero;
                    let mut sv2 = sv.clone();
                    sv2.d[i] = Value::One;
                    av.push(sv2);
                }

                v.append(&mut av);
            }
        }
        v
    }

    pub fn to_num(&self) -> u64 {
        self.d
            .iter()
            .enumerate()
            .map(|(i, v)| match v {
                Value::Zero | Value::X => 0,
                Value::One => 1 << i,
            })
            .sum()
    }
}

impl ToString for Vector {
    fn to_string(&self) -> String {
        self.d
            .chunks(8)
            .map(|chunk| {
                chunk
                    .iter()
                    .map(|v| match v {
                        Value::Zero => '0',
                        Value::One => '1',
                        Value::X => 'X',
                    })
                    .collect::<String>()
            })
            .collect::<Vec<String>>()
            .join("_")
    }
}

impl Debug for Vector {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Vector [{}]", self.to_string())
    }
}

impl Index<usize> for Vector {
    type Output = Value;

    fn index(&self, index: usize) -> &Self::Output {
        &self.d[index]
    }
}

impl IndexMut<usize> for Vector {
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.d[index]
    }
}

impl Into<u64> for Vector {
    fn into(self) -> u64 {
        self.to_num()
    }
}

#[cfg(test)]
mod test {
    use crate::vector::{Value, Vector};

    #[test]
    fn from_string() {
        let v = Vector::from_str("0101_xx_11_00");

        assert_eq!(v[0], Value::Zero);
        assert_eq!(v[1], Value::Zero);

        assert_eq!(v[2], Value::One);
        assert_eq!(v[3], Value::One);

        assert_eq!(v[4], Value::X);
        assert_eq!(v[5], Value::X);

        assert_eq!(v[6], Value::One);
        assert_eq!(v[7], Value::Zero);
        assert_eq!(v[8], Value::One);
        assert_eq!(v[9], Value::Zero);
    }

    #[test]
    fn from_number() {
        let v = Vector::from_number(0b10101100, 8);

        assert_eq!(v[0], Value::Zero);
        assert_eq!(v[1], Value::Zero);

        assert_eq!(v[2], Value::One);
        assert_eq!(v[3], Value::One);

        assert_eq!(v[4], Value::Zero);
        assert_eq!(v[5], Value::One);
        assert_eq!(v[6], Value::Zero);
        assert_eq!(v[7], Value::One);
    }

    #[test]
    fn to_num() {
        let v = Vector::from_str("0101_0011");
        assert_eq!(v.to_num(), 0b01010011);
    }
}
