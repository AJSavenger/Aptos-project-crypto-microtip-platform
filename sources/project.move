module MyModule::MicroTipPlatform {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    /// Struct representing a business that can receive tips
    struct Business has store, key {
        total_tips_received: u64,  // Total tips received by the business
        tip_count: u64,           // Number of tips received
        is_active: bool,          // Whether the business is accepting tips
    }
    
    /// Function for businesses (like restaurants) to register on the platform
    public fun register_business(business_owner: &signer) {
        let business = Business {
            total_tips_received: 0,
            tip_count: 0,
            is_active: true,
        };
        move_to(business_owner, business);
    }
    
    /// Function for users to send micro-tips to registered businesses
    public fun send_tip(
        tipper: &signer, 
        business_address: address, 
        tip_amount: u64
    ) acquires Business {
        // Get the business account and verify it exists
        let business = borrow_global_mut<Business>(business_address);
        
        // Check if business is active and accepting tips
        assert!(business.is_active, 1);
        
        // Transfer the tip from tipper to business
        let tip_coin = coin::withdraw<AptosCoin>(tipper, tip_amount);
        coin::deposit<AptosCoin>(business_address, tip_coin);
        
        // Update business statistics
        business.total_tips_received = business.total_tips_received + tip_amount;
        business.tip_count = business.tip_count + 1;
    }
}