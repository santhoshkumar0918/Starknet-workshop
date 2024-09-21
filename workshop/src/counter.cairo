#[starknet::interface]
trait ICounter<T>{
    fn get_counter(self: @T) -> u32;
    fn increase_counter(ref self: T);
}

#[starknet::contract]
pub mod counter_contract {
    use starknet::storage::StoragePointerWriteAccess;
    use core::starknet::event::EventEmitter;
    use super::{ICounter, ICounterDispatcher,ICounterDispatcherTrait};
    use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};
    
    #[storage]
    struct Storage {
        counter : u32,
        kill_switch: ContractAddress,
    }
    
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    struct CounterIncreased {
       #[key]
       pub value: u32
       
    }
    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        CounterIncreased: CounterIncreased
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_value: u32, _kill_switch: ContractAddress) {
        self.counter.write(initial_value);
        self.kill_switch.write(_kill_switch);
    }

    #[abi(embed_v0)]
    impl counter_contract of super::ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32{
            return self.counter.read();
        }
        fn increase_counter(ref self: ContractState) {
            let current_value = self.counter.read();
            self.counter.write(current_value + 1);

            self.emit(Event::CounterIncreased(CounterIncreased{value: self.counter.read()}));
        }
    }

    
    
}