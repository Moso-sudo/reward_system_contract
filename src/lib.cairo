use starknet::ContractAddress;
#[starknet::interface]
pub trait IRewardSystem<TContractState> {
    
    fn add_points(ref self: TContractState, user: ContractAddress, amount: u32);
    fn redeem_points(ref self: TContractState, user: ContractAddress, amount: u32);
}

#[starknet::contract]
mod RewardSystem {
    use starknet::storage::{Map};
    use starknet::ContractAddress;
    #[storage]
    pub struct Storage {
        pub balances: Map<ContractAddress, u32>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PointsAdded: PointsAdded,
        PointsRedeemed: PointsRedeemed,
        InsufficientBalance: InsufficientBalance
    }
    #[derive(Drop, starknet::Event)]
    pub struct PointsAdded {
        pub user: ContractAddress,
        pub amount: u32
    }

    #[derive(Drop, starknet::Event)]
    pub struct PointsRedeemed {
        pub user: ContractAddress,
        pub amount: u32
    }
    #[derive(Drop, starknet::Event)]
    pub struct InsufficientBalance {
        pub user: ContractAddress,
        pub requested_amount: u32,
        pub available_balance: u32,
    }

    #[abi(embed_v0)]
    impl RewardSystem of super::IRewardSystem<ContractState> {
        
    
        fn add_points(ref self: ContractState, user: ContractAddress, amount: u32) {
            let current_balance = self.balances.read(user); 
            let new_balance = current_balance + amount;

            self.balances.write(user, new_balance);
            self.emit(PointsAdded { user, amount });
        }

        fn redeem_points(ref self: ContractState, user: ContractAddress, amount: u32) {
            let current_balance = self.balances.read(user);
            if current_balance >= amount {
                let new_balance = current_balance - amount;

                self.balances.write(user, new_balance);
                self.emit(PointsRedeemed { user, amount });
            } else {
                self
                    .emit(
                        InsufficientBalance {
                            user, requested_amount: amount, available_balance: current_balance
                        }
                    );
            }
        }
    }
}