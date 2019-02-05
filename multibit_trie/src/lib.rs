pub mod trie;

extern crate libc;

use std::mem::transmute;
use libc::*;
use std::ffi::CStr;

#[no_mangle]
pub extern "C" fn make_fixedstridemultibit(stride: u8) -> *mut trie::FixedStrideMultiBit {
    let _fixedstridemultibit =
        unsafe { transmute(Box::new(trie::FixedStrideMultiBit::new(stride))) };
    _fixedstridemultibit
}

#[no_mangle]
pub extern "C" fn insert(ptr: *mut trie::FixedStrideMultiBit, ip: *const c_char) {
    let ip_str = unsafe { CStr::from_ptr(ip) }.to_str().unwrap().to_string();
    let mut _fixedstridemultibit = unsafe { &mut *ptr };
    _fixedstridemultibit.insert(ip_str);
}

#[no_mangle]
pub extern "C" fn search(ptr: *mut trie::FixedStrideMultiBit, ip: *const c_char) -> bool {
    let ip_str = unsafe { CStr::from_ptr(ip) }.to_str().unwrap().to_string();
    let mut _fixedstridemultibit = unsafe { &mut *ptr };
    _fixedstridemultibit.search(ip_str)
}
