pub fn pad_zeros(ip: String, expansion: u32) -> String {
    let mut zeros = "".to_string();
    for _ in 0..expansion {
        zeros.push_str("0");
    }
    zeros.push_str(&ip);
    return zeros;
}

pub fn int_to_binary(num: u8, digit: u32) -> String {
    let bin = format!("{:b}", num).to_string();
    let len = bin.len() as u32;
    return pad_zeros(bin, digit - len);
}

pub fn binary_to_int(bits: String) -> usize {
    let mut num = 0;
    for c in bits.chars() {
        num <<= 1;
        if c == '1' {
            num += 1;
        }
    }
    num
}

pub struct Node {
    pub is_in_list: bool,
    pub next_nodes: Vec<Node>,
}

impl Node {
    pub fn new(stride: u32) -> Node {
        let vec: Vec<Node> = Vec::with_capacity(2u32.pow(stride) as usize);
        Node {
            is_in_list: false,
            next_nodes: vec,
        }
    }

    pub fn create_children(&mut self, ip: String, numofbitshaveread: u8, stride: u8) {
        if numofbitshaveread == ip.len() as u8 {
            self.is_in_list = true;
            return;
        }
        if self.next_nodes.is_empty() == true {
            for _ in 0..2u8.pow(stride as u32) {
                self.next_nodes.push(Node::new(stride as u32))
            }
        }
        let num = binary_to_int(
            (&ip[(numofbitshaveread as usize)..(numofbitshaveread + stride) as usize])
                .to_string(),
        );
        self.next_nodes[num].create_children(ip, numofbitshaveread + stride, stride);

        // update is_in_list depending on lower level
        for i in 0..2u8.pow(stride as u32) {
            if !self.next_nodes[i as usize].is_in_list {
                return;
            }
        }
        self.is_in_list = true;
        return;
    }
}

pub struct FixedStrideMultiBit {
    pub root: Node,
    pub stride: u8,
}

impl FixedStrideMultiBit {
    pub fn new(stride: u8) -> FixedStrideMultiBit {
        FixedStrideMultiBit {
            root: Node::new(stride as u32),
            stride: stride,
        }
    }

    pub fn insert(&mut self, ip: String) {
        let remainder = (ip.len() as u8) % self.stride;
        if remainder == 0 {
            // insert single ip address
            self.root.create_children(ip, 0, self.stride);
        } else {
            let expansion = (self.stride - remainder) as u32;
            // insert multiple ip address
            for i in 0..2u8.pow(expansion) {
                let mut address = (&ip).to_string();
                address.push_str(&int_to_binary(i, expansion));
                self.root.create_children(address, 0, self.stride);
            }
        }
    }

    pub fn search(&self, ip: String) -> bool {
        let mut node = &self.root;
        let mut num = 0;
        let ip_address = binary_to_int(ip.clone()) as u32;
        let orig_mask = (1 << self.stride) - 1;
        loop {
            if node.is_in_list {
                return true;
            }
            if node.next_nodes.is_empty() || num >= ip.len() {
                return node.is_in_list;
            }
            let nextend = num + (self.stride as usize);
            if ip.len() < nextend {
                let expansion = nextend - ip.len();
                for i in 0..2u8.pow(expansion as u32) {
                    let mut address = (&ip).to_string();
                    address.push_str(&int_to_binary(i, expansion as u32));
                    if !&node.next_nodes[binary_to_int((&address[num..nextend]).to_string())]
                        .is_in_list
                    {
                        return false;
                    }
                }
                return true;
            } else {
                let shift = ip.len() - num - self.stride as usize;
                let mask = orig_mask << shift;
                let x: usize = ((ip_address & mask) >> shift) as usize;
                node = &node.next_nodes[x];
                num += self.stride as usize;
            }
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pad_zeros() {
        assert_eq!(pad_zeros("111".to_string(), 3), "000111");
        assert_eq!(pad_zeros("001".to_string(), 3), "000001");
        assert_eq!(pad_zeros("1".to_string(), 3), "0001");
    }

    #[test]
    fn test_int_to_binary() {
        assert_eq!(int_to_binary(5, 4), "0101");
    }

    #[test]
    fn test_binary_to_int() {
        assert_eq!(binary_to_int("01001".to_string()), 9);
    }

    #[test]
    fn test_insert() {
        let mut trie = FixedStrideMultiBit::new(3);
        trie.insert("10000".to_string());
        assert_eq!(trie.root.next_nodes[4].is_in_list, false);
        assert_eq!(trie.root.next_nodes[4].next_nodes[0].is_in_list, true);
        assert_eq!(trie.root.next_nodes[4].next_nodes[1].is_in_list, true);
        assert_eq!(trie.root.next_nodes[4].next_nodes[2].is_in_list, false);
        assert_eq!(trie.search("100010".to_string()), false);
        trie.insert("100".to_string());
        assert_eq!(trie.root.next_nodes[4].is_in_list, true);
        assert_eq!(trie.search("100010".to_string()), true);

    }

    #[test]
    fn test_fixed_stride_multitbit_trie_when_stride_is_equal_to_inserted_num() {
        let mut trie = FixedStrideMultiBit::new(3);
        trie.insert("100".to_string());
        trie.insert("001".to_string());
        assert_eq!(trie.search("100".to_string()), true);
        assert_eq!(trie.search("101".to_string()), false);
        assert_eq!(trie.search("000".to_string()), false);
        assert_eq!(trie.search("10000".to_string()), true);
    }

    #[test]
    fn test_fixed_stride_multitbit_trie_when_stride_is_not_equal_to_inserted_num() {
        let mut trie = FixedStrideMultiBit::new(3);
        trie.insert("10000".to_string());
        assert_eq!(trie.search("100000".to_string()), true);
        assert_eq!(trie.search("100001".to_string()), true);
        assert_eq!(trie.search("10000".to_string()), true);
        assert_eq!(trie.search("10100".to_string()), false);
        assert_eq!(trie.search("1000000".to_string()), true);
        trie.insert("1".to_string());
        assert_eq!(trie.search("1".to_string()), true);
        assert_eq!(trie.search("11".to_string()), true);
        assert_eq!(trie.search("111".to_string()), true);
    }

    #[test]
    fn test_updating_is_in_list() {
        let mut trie = FixedStrideMultiBit::new(3);
        trie.insert("101010000".to_string());
        assert_eq!(trie.search("101".to_string()), false);
        trie.insert("1010100".to_string());
        trie.insert("1010101".to_string());
        assert_eq!(trie.search("101010".to_string()), true);
        trie.insert("101011".to_string());
        assert_eq!(trie.search("10101".to_string()), true);
        trie.insert("10100".to_string());
        assert_eq!(trie.search("1010".to_string()), true);
        trie.insert("1011".to_string());
        assert_eq!(trie.search("101".to_string()), true);
    }

}
