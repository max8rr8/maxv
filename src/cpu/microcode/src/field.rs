use serde::{Deserialize, Deserializer};

use crate::vector::Vector;

pub const MICROCODE_POW2: usize = 10;
pub const MICROCODE_SIZE: usize = 1 << MICROCODE_POW2;

#[derive(Deserialize)]
struct FieldCfg {
    width: usize,
    default: Option<String>,
}

#[derive(Clone, Debug)]
pub struct Field {
    pub name: String,
    pub v: Vec<Vector>,
}

impl Field {
    pub fn new(name: String, width: usize) -> Field {
        let mut v = Vec::new();
        for _ in 0..width {
            v.push(Vector::with_size(MICROCODE_SIZE));
        }
        Field { name, v }
    }

    pub fn width(&self) -> usize {
        self.v.len()
    }

    pub fn net_name(&self, i: usize) -> String {
        let mut res = format!("mc_{}_o", self.name);

        if self.width() > 1 {
            res += format!("[{}]", i).as_str();
        }

        res
    }

    pub fn output_def(&self) -> String {
        let mut res = String::from("wire ");
        if self.width() > 1 {
            res += format!("[{}:0] ", self.width() - 1).as_str();
        }
        res += format!("mc_{}_o", self.name).as_str();
        res
    }

    pub fn from_cfg<'a>(name: String, t: impl Deserializer<'a>) -> Field {
        let cfg = FieldCfg::deserialize(t).expect("Failed to parse toml field");
        let mut f = Field::new(name, cfg.width);

        if let Some(default) = cfg.default {
            let default = Vector::from_str(&default);

            for i in 0..f.width() {
                f.v[i].set_all(default[i]);
            }
        }

        f
    }

    pub fn apply(&mut self, idx: usize, val: &Vector) {
        for (val, vec) in val.d.iter().zip(self.v.iter_mut()) {
            vec[idx] = *val;
        }
    }
}
