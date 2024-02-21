fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=.");
    if std::path::Path::new("private").exists() {
        // This is a bug, it should print unconditionally
    }
}
