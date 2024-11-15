module MyModule::DirectDonation {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    /// Error codes
    const E_NOT_REGISTERED: u64 = 1;
    const E_ALREADY_REGISTERED: u64 = 2;

    /// Struct to store beneficiary information
    struct BeneficiaryProfile has key {
        total_received: u64,    // Total donations received
        is_active: bool         // Whether the beneficiary is accepting donations
    }

    /// Function for beneficiaries to register themselves
    public entry fun register_beneficiary(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<BeneficiaryProfile>(addr), E_ALREADY_REGISTERED);
        
        let profile = BeneficiaryProfile {
            total_received: 0,
            is_active: true
        };
        move_to(account, profile);
    }

    /// Function for donors to send direct donations to beneficiaries
    public entry fun donate(
        donor: &signer,
        beneficiary_addr: address,
        amount: u64
    ) acquires BeneficiaryProfile {
        // Verify beneficiary is registered
        assert!(exists<BeneficiaryProfile>(beneficiary_addr), E_NOT_REGISTERED);
        
        // Get beneficiary profile and verify active status
        let profile = borrow_global_mut<BeneficiaryProfile>(beneficiary_addr);
        assert!(profile.is_active, E_NOT_REGISTERED);
        
        // Process the donation
        let donation = coin::withdraw<AptosCoin>(donor, amount);
        coin::deposit(beneficiary_addr, donation);
        profile.total_received = profile.total_received + amount;
    }
}
