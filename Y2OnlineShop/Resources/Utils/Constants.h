//
//  Constants.h
//  Y2OnlineShop
//
//  Created by maverick on 11/27/14.
//  Copyright (c) 2014 DIOS. All rights reserved.
//

#ifndef Y2OnlineShop_Constants_h
#define Y2OnlineShop_Constants_h

#ifdef DEBUG
    #define y2BaseURL @"http://192.168.1.161/shipshop/api/"
#else
    #define y2BaseURL @"https://tokoy2.com/api/"
#endif

#define homeMenu @"Home"
#define shopMenu @"Toko"
#define agentMenu @"Agen"
#define categoryMenu @"Kategori"
#define loginMenu @"Login"
#define registerMenu @"Daftar"
#define logoutMenu @"Logout"
#define myAccountMenu @"Akun Saya"
#define detailAccountMenu @"Detil Akun"
#define orderAccountMenu @"Order"
#define productMenu @"Produk"
#define salesMenu @"Sales"
#define orderMenu @"Order"
#define returMenu @"Retur"
#define footer1Menu @"Layanan"
#define footer2Menu @"Tentang Y2"
#define footer3Menu @"Pembayaran"
#define footer4Menu @"Pengiriman"
#define productGrosirMenu @"Grosir"
#define productRetailMenu @"Retail"

#define registerURL @"y2/register"
#define loginURL @"y2/login"
#define logoutURL @"y2/logout"
#define getTopBrandURL @"y2/get_top_brand"
#define getTopProductURL @"y2/get_top_product"
#define editProfileURL @"user/edit_profile"
#define editPasswordURL @"user/edit_password"
#define getFooterMenuURL @"y2/get_footer_content"
#define getFooterContentURL @"y2/get_content_category"
#define getSalesOrderListURL @"sales/get_orders_grosir"
#define getSalesOrderDetailURL @"sales/detail_order_grosir"
#define getSlideShowPromoURL @"y2/slide_show_promo"
#define getUserMenuURL @"y2/get_menu_by_user"
#define searchProductURL @"product/search_product"
#define getProductListURL @"user/get_list_user_product"

//not checked
#define getAllCategoryURL @"y2/get_all_category"
#define getAllStoreURL @"y2/get_store"
#define getAllAgentURL @"y2/get_agent"
#define getProductURL @"y2/get_product_by_id"
#define getProductGrosirURL @"y2/get_product_grosir_by_id"
#define getAllCityURL @"user/list_kota_kab"
#define cartCheckoutURL @"cart/checkout"
#define addItemToCartURL @"cart/add_item_to_cart"
#define addItemToCartBulkURL @"cart/add_item_to_cart_bulk"
#define paymentConfirmURL @"cart/payment_confirm"
#define getAllAccountURL @"cart/get_all_rekening"
#define getuserProfileURL @"user/get_user_profile"
#define getStockByIdURL @"cart/get_stock_by_id"
#define registerDeviceTokenURL @"user/insert_device_token"
#define unregisterDeviceTokenURL @"user/delete_device_token"
#define getOrderListURL @"user/get_list_order_user"
#define getOrderDetailURL @"user/get_detail_order_user"
#define confirmShippingURL @"product/shipping_confirmed"
#define getMessageHelperURL @"y2/get_message_helper"
#define getCategoryDataURL @"y2/get_category_data"
#define deleteProductURL @"product/delete_product"
#define getAllBrandURL @"y2/get_all_brand"
#define addProductGrosirURL @"product/add_product_grosir"
#define addImageProductURL @"product/add_image_product"
#define deleteImageProductURL @"product/delete_product_image"
#define getOrderStatusURL @"sales/get_order_status"
#define updateSalesOrderDetailURL @"sales/update_status"
#define getReturListURL @"cart/list_order_return"
#define getReturDetailURL @"cart/detail_order_return"
#define getReturStatusURL @"cart/get_list_status_return"
#define requestReturnURL @"cart/request_return"
#define updateReturStatusURL @"cart/update_status_return"
#define forgotPasswordURL @"user/forgot_password"
#define addProductRetailURL @"product/save_product_retail"
#define getOptionValuesURL @"product/get_options"
#define getPaymentInfoURL @"cart/payment_info"
#define deleteVariantURL @"product/delete_variant"
#define saveUserReviewURL @"y2/save_review"
#define getTopSellerURL @"y2/top_seller"
#define getUserMenuTreeURL @"y2/user_menu_tree"
#define getProductCategoryURL @"y2/get_category"
#define getVideoHomeURL @"y2/get_video_home"

//not use
#define getProductByCatIdURL @"y2/get_product_by_category_id"
#define getStoreProduct @"y2/get_product_by_category_owner_id"
#define getStoreProductGrocier @"y2/get_product_grosir_by_category_owner_id"
#define getAllProductByOwnerURL @"y2/get_product_by_owner_id"
#define getAllProductGrosirByOwnerURL @"y2/get_product_grosir_by_owner_id"


#define title_error @"Gagal"
#define title_success @"Sukses"
#define message_connection_error @"Tidak dapat terhubung dengan server"
#define message_no_privilege @"Anda tidak dapat mengunjungi toko ini"
#define message_request_failed @"Request Failed"
#define message_success_register @"Terima kasih, anda telah terdaftar"
#define message_error_server @"Terdapat kesalahan pada server,silakan hubungi admin Y2"
#define message_out_of_stock @"Maaf, tidak ada stok untuk produk ini"
#define message_out_of_stock_variant @"Maaf, tidak ada stok untuk produk ini yang sesuai dengan varian yang dipilih"

#define database_version 8
#define boris_random(smallNumber, bigNumber) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (bigNumber - smallNumber)) + smallNumber) 
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define search_bar_grosir 5
#define search_bar_retail 6

#define CART_CATEGORY 1
#define CART_AGENT 2
#define CART_SHOP 3

#define MALE_ID 1
#define FEMALE_ID 0
#define UNSELECT_GENDER -1
#define Male @"Pria"
#define Female @"Wanita"

#define transscript_filepath @"/transscript.png"

#define spaceLogoToTitle 5.0f

//regex validation
#define regex_email @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
#define regex_password @"^.{3,}$"
#define regex_name @"[A-Za-z0-9 ]{1,}$"
#define regex_gender @"^.{1,}$"
#define regex_birthdate @"^.{1,}$"
#define regex_phone @"[0-9]{6,16}"
#define regex_phoneOther regex_phone
#define regex_value @"^\\s*[-+]?\\s*[0-9]+\\s*$"
#define regex_city @"[A-Za-z ]{1,}$"
#define regex_bankname @"[A-Za-z0-9]{1,}$"
#define regex_accountnumber @"[0-9]{1,}$"
#define regex_sku @"[A-Za-z0-9]{1,}$"
#define regex_product_name @"[A-Za-z0-9]{1,}$"
#define regex_user_name @"^.{1,}$"

#define productKey @"product"
#define quantityKey @"quantity"
#define ownerIDKey @"cart_owner"
#define ownerItemsKey @"cart_owner_items"
#define cartExpenseKey @"cart_expense"
#define ownerNameKey @"cart_owner_name"
#define cartSellerRoleKey @"cart_seller_role"
#define cartOwnerIDRetail -2
#define cartOwnerIDToko -3

#define stock_prd_sku_key @"stock_product_sku"
#define stock_qty_id_key @"stock_qty_id"
#define stock_qty_key @"stock_qty"

#define variant_data_key @"variant_data"
#define variant_data_selected_id @"variant_data_id"
#define variant_data_selected_option @"variant_data_opt"
#define variant_data_selected_value @"variant_data_val"

#define variant_option_key @"var_opt"
#define variant_value_key @"var_val"
#define variant_selected_key @"var_selected"
#define variant_selected_data @"var_selected_data"

#define product_option_key @"option_value_product"
#define product_option_complete_key @"option_value_product_complete"

#define date_format @"dd/MM/yyyy"
#define order_date_format @"dd-MM-yyyy HH:mm:ss"
#define sales_order_date_format @"dd-MM-yyyy"

#define y2AdminCode @"3"
#define memberCode @"2"
#define shopOwnerCode @"4"
#define agentCode @"5"
#define subagentCode @"6"

#define IS_SHOPOWNER 1
#define IS_AGENT 2
#define IS_SUBAGENT 3
#define IS_MEMBER 4
#define IS_USER 5

#define getTopBrand 1
#define getTopProduct 2
#define getAllCategory 3
#define getCategoryByBrandAgent 4
#define getCategoryByParentId 5
#define getCategoryByGender 6
#define getProductByBrandId 7
#define getProductByCategoryId 8
#define getWishList 9
#define getCart 10
#define getAllStore 11
#define getAllAgent 12
#define getProductWishlist 13
#define getProductShopCart 14
#define getAllCity 15
#define getAllAccount 16
#define getUserProfile 17
#define registerDeviceToken 18
#define unregisterDeviceToken 19
#define getOrderList 20
#define getOrderDetail 21
#define confirmShipping 22
#define getUserMenu 23
#define getMessageHelper 24
#define getCategoryData 25
#define getAllBrand 26
#define addProductGrosir 27
#define editProductGrosir 28
#define addProductImage 29
#define getStockData 30
#define getOrderStatus 31
#define userLogout 32
#define getProduct 33
#define getBrandProduct 34
#define searchProduct 35
#define getReturStatus 36
#define requestReturn 37
#define getFooterContent1 38
#define getFooterContent2 39
#define getOptionValues 40
#define addProductRetail 41
#define editProductRetail 42
#define getVideoHome 43
#define deleteProduct 44
#define deleteProductImage 45
#define getPaymentInformation 46
#define getAllRekening 47
#define deleteVariant 48
#define saveUserReview 49
#define getTopSeller 50
#define getSlideShowPromo 51
#define getUserMenuTree 52
#define getProductCategory 53

#define order1stCol @"no_order"
#define order2ndCol @"produk"
#define order3rdCol @"total"
#define order4thCol @"pengiriman"
#define order5thCol @"status"
#define order6thCol @"action"

#define FONT_ARSENAL(s) [UIFont fontWithName:@"Arsenal-Regular" size:s]
#define FONT_ARSENAL_BOLD(s) [UIFont fontWithName:@"Arsenal-Bold" size:s]
#define COLOR_PINK_Y2 [UIColor colorWithRed:236/255.0 green:0/255.0 blue:140/255.0 alpha:1.0]
#define COLOR_GREY_Y2 [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0]
#define tableReturBgColor [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:0.3]

#define needConfirmationOrderCode 4
#define orderCompleteCode 5

#define markDetailedProduct @"detailed"

#define y2website @"https://tokoy2.com"

#define loremIpsumText @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."

#endif
