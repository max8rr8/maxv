use std::{
    collections::HashMap,
    fmt::{self, Write},
};

use serde::Deserialize;
use toml::Table;

use crate::{
    field::{Field, MICROCODE_SIZE},
    vector::Vector,
};

mod field;
mod vector;

#[derive(Deserialize, Clone, Debug)]
struct InstructionCfg {
    encoding: String,
    code: Vec<HashMap<String, String>>,
}

fn write_prologue(fields: &Vec<Field>, sv_out: &mut dyn fmt::Write) -> Result<(), fmt::Error> {
    writeln!(sv_out, "`default_nettype none")?;
    writeln!(sv_out, "")?;

    writeln!(sv_out, "module microcode_data (")?;
    for f in fields {
        writeln!(sv_out, "\toutput {},", f.output_def())?;
    }

    writeln!(sv_out, "")?;
    writeln!(sv_out, "\tinput logic clk_i,")?;
    writeln!(sv_out, "\tinput logic rst_i,")?;
    writeln!(sv_out, "\tinput logic decode_en_i,")?;
    writeln!(
        sv_out,
        "\tinput logic [{}:0] mc_addr_i",
        (MICROCODE_SIZE - 1).ilog2()
    )?;
    writeln!(sv_out, ");")?;
    writeln!(sv_out, "")?;

    Ok(())
}

fn write_prom(fields: &Vec<Field>, sv_out: &mut dyn fmt::Write) -> Result<(), fmt::Error> {
    let mut names: Vec<String> = Vec::new();
    let mut vecs: Vec<&Vector> = Vec::new();

    for f in fields {
        for i in 0..f.width() {
            names.push(f.net_name(i));
            vecs.push(&f.v[i]);
        }
    }

    let zvec = Vector::with_size(MICROCODE_SIZE);
    while vecs.len() < 16 {
        vecs.push(&zvec);
    }

    writeln!(sv_out, "\tlogic [31:0] prom_out;")?;
    writeln!(sv_out, "")?;
    writeln!(sv_out, "\tpROM #(")?;
    writeln!(sv_out, "\t\t.BIT_WIDTH({}),", 16)?;

    for prom_init_i in 0..0x40 {
        let mut strvec = String::with_capacity(256);
        for loc_i in 0..16 {
            for v in &vecs {
                strvec.push(match v[prom_init_i * 16 + loc_i] {
                    vector::Value::Zero => '0',
                    vector::Value::One => '1',
                    vector::Value::X => '0',
                });
            }
        }
        // strvec.reve
        writeln!(
            sv_out,
            "\t\t.INIT_RAM_{:02X}(256'b{}),",
            prom_init_i,
            strvec.chars().rev().collect::<String>()
        )?;
    }

    writeln!(sv_out, "\t\t.READ_MODE(0),")?;
    writeln!(sv_out, "\t\t.RESET_MODE(\"SYNC\")")?;
    writeln!(sv_out, "\t) mc_prom (")?;
    writeln!(sv_out, "\t\t.AD({{mc_addr_i, 4'b0}}),")?;
    writeln!(sv_out, "\t\t.CE(decode_en_i),")?;
    writeln!(sv_out, "\t\t.CLK(clk_i),")?;
    writeln!(sv_out, "\t\t.DO(prom_out),")?;
    writeln!(sv_out, "\t\t.OCE(1),")?;
    writeln!(sv_out, "\t\t.RESET(rst_i)")?;
    writeln!(sv_out, "\t);")?;
    writeln!(sv_out, "")?;

    for (i, name) in names.iter().enumerate() {
        writeln!(sv_out, "\tassign {} = prom_out[{}];", name, i)?;
    }

    Ok(())
}

fn main() {
    let mut args = std::env::args().skip(1);

    let toml_path = args.next().unwrap();
    let sv_path = args.next().unwrap();

    let toml = std::fs::read_to_string(toml_path).expect("Failed to read toml file");
    let toml = toml.parse::<Table>().expect("Failed to parse toml file");

    let mut fields: Vec<_> = toml["fields"]
        .as_table()
        .expect("Didn't find fileds table")
        .iter()
        .map(|(k, v)| {
            let t = v.clone();
            Field::from_cfg(k.clone(), t)
        })
        .collect();

    let mut instrs: Vec<_> = toml
        .iter()
        .filter(|x| {
            x.1.as_table()
                .and_then(|x| Some(x.contains_key("encoding")))
                .unwrap_or(false)
        })
        .map(|(name, cfg)| {
            (
                name,
                InstructionCfg::deserialize(cfg.clone())
                    .expect("Failed to deserialize instruction"),
            )
        })
        .collect();

    instrs.sort_by_key(|x| {
        -(x.1
            .encoding
            .chars()
            .filter(|x| *x == 'X' || *x == 'x')
            .count() as i32)
    });

    for (name, instr_cfg) in instrs {
        // let instr_cfg: InstructionCfg = ;

        let variants: Vec<usize> = Vector::from_str(&instr_cfg.encoding)
            .variate()
            .into_iter()
            .map(|x| x.to_num() as usize)
            .collect();

        for code in instr_cfg.code {
            fields.iter_mut().for_each(|x| {
                if let Some(val) = code.get(&x.name) {
                    dbg!((name, &x.name));
                    let val = Vector::from_str(val);

                    for variant in &variants {
                        x.apply(*variant << 2, &val);
                    }
                }
            });
        }
    }
    // dbg!(instrs.collect::<Vec<_>>());

    let mut sv_out = String::with_capacity(16 * 1024);
    write_prologue(&fields, &mut sv_out).expect("Failed to write prologue");
    write_prom(&fields, &mut sv_out).expect("Failed to write prom");
    writeln!(sv_out, "endmodule").unwrap();
    std::fs::write(sv_path, sv_out).expect("Failed to write SV output");
}
