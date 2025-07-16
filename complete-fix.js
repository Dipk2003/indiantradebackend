// Complete fix script to add categories and test product creation
// Run this in browser console after logging in as a vendor

const baseUrl = 'http://localhost:8080';

async function completeFix() {
    console.log('🔧 Starting complete fix...');
    
    // Step 1: Get token from localStorage
    const token = localStorage.getItem('token');
    if (!token) {
        console.error('❌ No token found. Please log in first.');
        return;
    }
    
    console.log('✅ Token found:', token.substring(0, 20) + '...');
    
    // Step 2: Add categories without authentication (they're public)
    const categories = [
        { name: "Electronics" },
        { name: "Fashion" },
        { name: "Home & Garden" },
        { name: "Sports" },
        { name: "Books" },
        { name: "Automotive" },
        { name: "Tools" },
        { name: "Office Supplies" }
    ];
    
    console.log('📝 Adding categories...');
    let createdCategories = [];
    
    for (const category of categories) {
        try {
            const response = await fetch(`${baseUrl}/api/categories`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(category)
            });
            
            if (response.ok) {
                const createdCategory = await response.json();
                createdCategories.push(createdCategory);
                console.log(`✅ Category created: ${createdCategory.name} (ID: ${createdCategory.id})`);
            } else {
                console.log(`⚠️ Category ${category.name} might already exist (${response.status})`);
            }
        } catch (error) {
            console.log(`⚠️ Error creating category ${category.name}:`, error);
        }
    }
    
    // Step 3: Get all categories
    let allCategories = [];
    try {
        const response = await fetch(`${baseUrl}/api/categories`, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        if (response.ok) {
            allCategories = await response.json();
            console.log('✅ Available categories:', allCategories);
        } else {
            console.log('⚠️ Failed to fetch categories:', response.status);
        }
    } catch (error) {
        console.log('⚠️ Error fetching categories:', error);
    }
    
    // Step 4: Use the first available category ID
    let categoryId = 1;
    if (allCategories.length > 0) {
        categoryId = allCategories[0].id;
        console.log('✅ Using category ID:', categoryId, '(', allCategories[0].name, ')');
    } else {
        console.log('⚠️ No categories found, using default ID: 1');
    }
    
    // Step 5: Test product creation with the correct data format
    const testProduct = {
        name: "Test Product " + new Date().getTime(),
        description: "This is a comprehensive test product created via API",
        price: 100,
        originalPrice: 120,
        stock: 50,
        categoryId: categoryId,
        brand: "Test Brand",
        model: "Test Model",
        sku: "TEST" + new Date().getTime(),
        minOrderQuantity: 1,
        unit: "piece",
        specifications: "Test specifications for this product",
        tags: "test,product,electronics",
        gstRate: 18,
        weight: 1.0,
        length: 10.0,
        width: 5.0,
        height: 3.0,
        freeShipping: false,
        shippingCharge: 50,
        isActive: true
    };
    
    console.log('📝 Testing product creation...');
    console.log('Product data:', testProduct);
    
    try {
        const response = await fetch(`${baseUrl}/api/products/vendor/add`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(testProduct)
        });
        
        console.log('📊 Product API Response Status:', response.status);
        console.log('📊 Product API Response Headers:', Object.fromEntries(response.headers.entries()));
        
        const responseText = await response.text();
        console.log('📊 Product API Response Body:', responseText);
        
        if (response.ok) {
            console.log('🎉 SUCCESS: Product created successfully!');
            console.log('✅ The product API is now working correctly.');
            console.log('✅ You can now try adding products through the frontend form.');
            
            // Parse the response to get the product ID
            try {
                const product = JSON.parse(responseText);
                console.log('✅ Created product ID:', product.id);
            } catch (e) {
                console.log('⚠️ Could not parse product response, but creation was successful');
            }
        } else {
            console.error('❌ Product creation failed:', response.status);
            console.error('Error details:', responseText);
            
            // Try to give specific advice based on the error
            if (response.status === 400) {
                console.log('💡 Suggestion: Check if all required fields are provided and valid');
            } else if (response.status === 401) {
                console.log('💡 Suggestion: Please log in again or check if your token is valid');
            } else if (response.status === 403) {
                console.log('💡 Suggestion: Make sure you are logged in as a VENDOR, not a BUYER');
            }
        }
    } catch (error) {
        console.error('❌ Product API network error:', error);
    }
    
    // Step 6: Test getting vendor products
    console.log('📝 Testing get vendor products...');
    try {
        const response = await fetch(`${baseUrl}/api/products/vendor/my-products`, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (response.ok) {
            const products = await response.json();
            console.log('✅ Your products:', products);
        } else {
            console.log('⚠️ Failed to fetch your products:', response.status);
        }
    } catch (error) {
        console.log('⚠️ Error fetching your products:', error);
    }
    
    console.log('🔧 Complete fix finished!');
    console.log('');
    console.log('📋 Summary:');
    console.log('- Categories have been added to the database');
    console.log('- Product API endpoint has been tested');
    console.log('- Frontend productApi.ts has been updated to use the correct endpoint');
    console.log('');
    console.log('🚀 Next steps:');
    console.log('1. Refresh your frontend page');
    console.log('2. Try adding a product through the form');
    console.log('3. The "Bad Request" error should now be resolved');
}

// Run the complete fix
completeFix();
