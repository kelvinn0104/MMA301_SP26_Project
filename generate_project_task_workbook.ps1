param(
  [string]$OutputPath = (Join-Path $PSScriptRoot "MMA301_Project_Tasks.xlsx")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ExcelColumnName {
  param([int]$ColumnNumber)

  $dividend = $ColumnNumber
  $columnName = ""
  while ($dividend -gt 0) {
    $modulo = ($dividend - 1) % 26
    $columnName = [char](65 + $modulo) + $columnName
    $dividend = [math]::Floor(($dividend - $modulo) / 26)
  }
  return $columnName
}

function Set-TableStyle {
  param(
    $Worksheet,
    [int]$HeaderRow,
    [int]$ColumnCount,
    [int]$LastRow
  )

  $lastColumn = Get-ExcelColumnName -ColumnNumber $ColumnCount
  $headerRange = $Worksheet.Range("A$HeaderRow", "$lastColumn$HeaderRow")
  $dataRange = $Worksheet.Range("A1", "$lastColumn$LastRow")

  $headerRange.Font.Bold = $true
  $headerRange.Font.Color = 0xFFFFFF
  $headerRange.Interior.Color = 0x2F5597
  $headerRange.HorizontalAlignment = -4108
  $headerRange.VerticalAlignment = -4108

  $dataRange.Borders.LineStyle = 1
  $dataRange.VerticalAlignment = -4160
  $dataRange.WrapText = $true
  $dataRange.EntireColumn.AutoFit() | Out-Null

  $Worksheet.Range("A$HeaderRow").AutoFilter() | Out-Null
  $Worksheet.Activate() | Out-Null
  $Worksheet.Application.ActiveWindow.SplitRow = $HeaderRow
  $Worksheet.Application.ActiveWindow.FreezePanes = $true
}

function Apply-StatusColors {
  param(
    $Worksheet,
    [int]$StatusColumn,
    [int]$StartRow,
    [int]$EndRow
  )

  for ($row = $StartRow; $row -le $EndRow; $row++) {
    $cell = $Worksheet.Cells.Item($row, $StatusColumn)
    $value = [string]$cell.Value2
    switch ($value) {
      "Done" {
        $cell.Interior.Color = 0xC6EFCE
        $cell.Font.Color = 0x006100
      }
      "Partial" {
        $cell.Interior.Color = 0xFFEB9C
        $cell.Font.Color = 0x9C6500
      }
      "Backlog" {
        $cell.Interior.Color = 0xFFC7CE
        $cell.Font.Color = 0x9C0006
      }
      default { }
    }
  }
}

function Write-ObjectRows {
  param(
    $Worksheet,
    [array]$Rows
  )

  if ($Rows.Count -eq 0) {
    return
  }

  $headers = @($Rows[0].PSObject.Properties.Name)
  for ($column = 0; $column -lt $headers.Count; $column++) {
    $Worksheet.Cells.Item(1, $column + 1) = $headers[$column]
  }

  for ($rowIndex = 0; $rowIndex -lt $Rows.Count; $rowIndex++) {
    $row = $Rows[$rowIndex]
    for ($column = 0; $column -lt $headers.Count; $column++) {
      $header = $headers[$column]
      $Worksheet.Cells.Item($rowIndex + 2, $column + 1) = [string]$row.$header
    }
  }

  Set-TableStyle -Worksheet $Worksheet -HeaderRow 1 -ColumnCount $headers.Count -LastRow ($Rows.Count + 1)
}

$taskRows = @(
  [pscustomobject]@{No=1;Epic="Customer Experience";TaskName="Register, login, current-user, profile update, password change";Scope="Auth and identity";Platform="Backend + Web + Mobile";MainRole="Guest/User";Priority="High";Status="Done";KeyDeliverables="JWT auth, protected routes, token persistence, user self-service";SourceReference="backend/src/routes/authRoutes.js; frontend/pages/auth/AuthPage.jsx; mobile_app/app/auth/index.tsx";Notes="Foundation for every other flow"},
  [pscustomobject]@{No=2;Epic="Customer Experience";TaskName="Profile management and account information update";Scope="User profile";Platform="Backend + Web";MainRole="User";Priority="High";Status="Done";KeyDeliverables="View profile, update personal data, keep account state synced";SourceReference="backend/src/controllers/authControllers.js; frontend/pages/profile/Profile.jsx";Notes="Mobile app currently focuses on auth and shopping flow"},
  [pscustomobject]@{No=3;Epic="Customer Experience";TaskName="Homepage with promotions, navigation, and category entry points";Scope="Storefront";Platform="Web + Mobile";MainRole="Guest/User";Priority="High";Status="Done";KeyDeliverables="Landing page, banners, product entry points, shared brand navigation";SourceReference="frontend/pages/homepage/Homepage.jsx; mobile_app/app/index.tsx";Notes="Primary discovery surface"},
  [pscustomobject]@{No=4;Epic="Customer Experience";TaskName="Product listing with search/filter/pagination support";Scope="Catalog browsing";Platform="Backend + Web + Mobile";MainRole="Guest/User";Priority="High";Status="Done";KeyDeliverables="List products, category filtering, query params, pagination component";SourceReference="backend/src/routes/productsRoutes.js; frontend/pages/shop/shop.jsx; frontend/src/components/pagination/Pagination.jsx; mobile_app/app/shop/index.tsx";Notes="Core shopping journey"},
  [pscustomobject]@{No=5;Epic="Customer Experience";TaskName="Best-seller product discovery";Scope="Catalog highlight";Platform="Backend + Web + Mobile";MainRole="Guest/User";Priority="Medium";Status="Done";KeyDeliverables="Dedicated best-seller endpoint and screens";SourceReference="backend/src/controllers/productControllers.js; frontend/pages/bestseller/BestSeller.jsx; mobile_app/app/bestseller.tsx";Notes="Marketing-oriented listing"},
  [pscustomobject]@{No=6;Epic="Customer Experience";TaskName="Product detail page with images, sizes, and purchase actions";Scope="Product detail";Platform="Backend + Web + Mobile";MainRole="Guest/User";Priority="High";Status="Done";KeyDeliverables="Product detail API, selected size flow, quick-view/detail screens";SourceReference="backend/src/controllers/productControllers.js; frontend/pages/Detail-card/Detailcard.jsx; mobile_app/app/product/[id].tsx";Notes="Supports add-to-cart decision"},
  [pscustomobject]@{No=7;Epic="Customer Experience";TaskName="Product review eligibility and review CRUD";Scope="Review system";Platform="Backend + Web";MainRole="User";Priority="Medium";Status="Done";KeyDeliverables="Can-review check, create/update/delete review, average rating refresh";SourceReference="backend/src/routes/reviewRoutes.js; backend/src/controllers/reviewControllers.js";Notes="Visible customer trust feature"},
  [pscustomobject]@{No=8;Epic="Customer Experience";TaskName="Shopping cart and cart-item management";Scope="Cart";Platform="Backend + Web + Mobile";MainRole="User";Priority="High";Status="Done";KeyDeliverables="Get my cart, add item, update quantity, remove item";SourceReference="backend/src/routes/cartRoutes.js; backend/src/routes/cartItemRoutes.js; frontend/src/components/cart/Cart.jsx; mobile_app/app/cart.tsx";Notes="Uses dedicated cart and cart-item models"},
  [pscustomobject]@{No=9;Epic="Customer Experience";TaskName="Checkout and order creation";Scope="Order placement";Platform="Backend + Web + Mobile";MainRole="User";Priority="High";Status="Done";KeyDeliverables="Create order, shipping address capture, payment method selection";SourceReference="backend/src/routes/orderRoutes.js; frontend/pages/order/Order.jsx; mobile_app/app/order.tsx";Notes="Central revenue flow"},
  [pscustomobject]@{No=10;Epic="Customer Experience";TaskName="Order history, order detail, and self-cancellation";Scope="Order lifecycle";Platform="Backend + Web + Mobile";MainRole="User";Priority="High";Status="Done";KeyDeliverables="Get my orders, get order by id, cancel pending order";SourceReference="backend/src/controllers/orderControllers.js; mobile_app/api/index.tsx";Notes="Web and mobile consume the same order APIs"},
  [pscustomobject]@{No=11;Epic="Payment";TaskName="VNPay payment URL generation, return handling, and IPN handling";Scope="Online payment";Platform="Backend + Web";MainRole="User";Priority="High";Status="Done";KeyDeliverables="Create VNPay URL, verify return params, process payment callbacks";SourceReference="backend/src/routes/vnpayRoutes.js; backend/src/controllers/vnpayControllers.js; frontend/pages/payment/VnpayReturn.jsx";Notes="Supports real payment gateway integration"},
  [pscustomobject]@{No=12;Epic="AI Features";TaskName="Web chatbot widget integration";Scope="AI assistant UI";Platform="Backend + Web";MainRole="User";Priority="Medium";Status="Done";KeyDeliverables="Floating chatbot widget, auth-aware chat trigger, product-aware prompts";SourceReference="frontend/src/components/chatbot/ChatbotWidget.jsx; backend/src/routes/chatbotRoutes.js";Notes="Visible on routed web app"},
  [pscustomobject]@{No=13;Epic="AI Features";TaskName="Gemini chatbot backend with personal chat history";Scope="AI assistant service";Platform="Backend";MainRole="User";Priority="Medium";Status="Done";KeyDeliverables="Chat endpoint, Gemini service wrapper, per-user chat history";SourceReference="backend/src/controllers/chatbotControllers.js; backend/src/services/gemini.js";Notes="Protected by token auth"},
  [pscustomobject]@{No=14;Epic="AI Features";TaskName="AI recommendation CRUD and recommendation generation";Scope="Recommendation engine";Platform="Backend";MainRole="Admin/User";Priority="Medium";Status="Done";KeyDeliverables="Generate recommendations, admin CRUD for recommendation records";SourceReference="backend/src/routes/aiRecommendationRoutes.js; backend/src/controllers/aiRecommendationControllers.js";Notes="Mix of user-facing generation and admin maintenance"},
  [pscustomobject]@{No=15;Epic="AI Features";TaskName="AI behavior logging and chatbot log retention";Scope="AI observability";Platform="Backend + Web(Admin) + Mobile(Admin)";MainRole="Admin/User";Priority="Medium";Status="Done";KeyDeliverables="Create behavior logs, view my logs, admin list/detail/delete logs";SourceReference="backend/src/routes/aiBehaviorLogRoutes.js; backend/src/routes/chatbotLogRoutes.js; frontend/pages/admin/AIBehaviorLogs.jsx; mobile_app/app/admin/ai-logs.tsx";Notes="Useful for audit and tuning"},
  [pscustomobject]@{No=16;Epic="Catalog Management";TaskName="Category CRUD and category browsing";Scope="Categories";Platform="Backend + Web(Admin/Manager) + Mobile(Admin)";MainRole="Admin/Manager";Priority="High";Status="Done";KeyDeliverables="List categories for shoppers, create/update/delete categories for management";SourceReference="backend/src/routes/categoryRoutes.js; frontend/pages/admin/CategoryManagement.jsx; frontend/pages/manager/ManagerCategories.jsx; mobile_app/app/admin/categories.tsx";Notes="Shared across storefront and back office"},
  [pscustomobject]@{No=17;Epic="Catalog Management";TaskName="Product CRUD for admin and manager operations";Scope="Product management";Platform="Backend + Web(Admin/Manager) + Mobile(Admin)";MainRole="Admin/Manager";Priority="High";Status="Done";KeyDeliverables="Create, update, delete products with stock, category, image, and size metadata";SourceReference="backend/src/routes/productsRoutes.js; backend/src/routes/managerRoutes.js; frontend/pages/admin/ProductManagement.jsx; frontend/pages/manager/ManagerProducts.jsx; mobile_app/app/admin/products.tsx";Notes="Customer catalog depends on these records"},
  [pscustomobject]@{No=18;Epic="Order Management";TaskName="Order management API and line-item support";Scope="Operations backend";Platform="Backend";MainRole="Admin/Manager/Staff";Priority="High";Status="Done";KeyDeliverables="Order CRUD, protected order-item CRUD, status updates and access control";SourceReference="backend/src/routes/orderRoutes.js; backend/src/routes/orderItemRoutes.js";Notes="Used by multiple roles"},
  [pscustomobject]@{No=19;Epic="Order Management";TaskName="Payment record CRUD for administrative operations";Scope="Payments back office";Platform="Backend";MainRole="Admin";Priority="Medium";Status="Done";KeyDeliverables="List, create, update, delete payment records";SourceReference="backend/src/routes/paymentRoutes.js; backend/src/controllers/paymentControllers.js";Notes="Separate from VNPay gateway callbacks"},
  [pscustomobject]@{No=20;Epic="Access Control";TaskName="Role CRUD and role-permission mapping";Scope="RBAC";Platform="Backend";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Create role, update role, assign permissions, remove permissions";SourceReference="backend/src/routes/rolesRoutes.js; backend/src/controllers/roleControllers.js";Notes="Supports both legacy role field and role documents"},
  [pscustomobject]@{No=21;Epic="Access Control";TaskName="Permission CRUD and permission catalog";Scope="RBAC";Platform="Backend";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Permission list/detail/create/update/delete";SourceReference="backend/src/routes/permissionsRoutes.js; backend/src/controllers/permissionControllers.js";Notes="Used by requirePermission middleware"},
  [pscustomobject]@{No=22;Epic="Access Control";TaskName="Assign and remove roles for specific users";Scope="User-role assignment";Platform="Backend + Web(Admin)";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Get user roles, assign role ids, remove role ids";SourceReference="backend/src/routes/userRoleRoutes.js; frontend/pages/admin/UserManagement.jsx";Notes="Administrative identity control"},
  [pscustomobject]@{No=23;Epic="Admin Module";TaskName="Admin dashboard analytics";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Revenue chart, order status chart, recent orders, KPI cards";SourceReference="backend/src/routes/statsRoutes.js; frontend/pages/admin/Dashboard.jsx; mobile_app/app/admin/dashboard.tsx";Notes="Shared dashboard data contract"},
  [pscustomobject]@{No=24;Epic="Admin Module";TaskName="Admin user management";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="List users, view user detail, update user, delete user, assign roles";SourceReference="backend/src/routes/userRoutes.js; frontend/pages/admin/UserManagement.jsx; mobile_app/app/admin/users.tsx";Notes="Combines user and role management"},
  [pscustomobject]@{No=25;Epic="Admin Module";TaskName="Admin product management";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Manage catalog entries, stock, prices, and category mapping";SourceReference="frontend/pages/admin/ProductManagement.jsx; mobile_app/app/admin/products.tsx; backend/src/routes/productsRoutes.js";Notes="Admin has direct product CRUD access"},
  [pscustomobject]@{No=26;Epic="Admin Module";TaskName="Admin category management";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Maintain category list and category hierarchy references";SourceReference="frontend/pages/admin/CategoryManagement.jsx; mobile_app/app/admin/categories.tsx; backend/src/routes/categoryRoutes.js";Notes="Mobile admin mirrors core web actions"},
  [pscustomobject]@{No=27;Epic="Admin Module";TaskName="Admin order management";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="View orders, inspect order status, update operational state";SourceReference="frontend/pages/admin/OrderManagement.jsx; mobile_app/app/admin/orders.tsx; backend/src/routes/orderRoutes.js";Notes="Depends on permissions and order APIs"},
  [pscustomobject]@{No=28;Epic="Admin Module";TaskName="Admin reports and analytics";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Sales report, top products, revenue by category, customer stats, inventory report";SourceReference="backend/src/routes/reportRoutes.js; frontend/pages/admin/ReportsAnalytics.jsx; mobile_app/app/admin/reports.tsx";Notes="Dedicated admin-only reporting endpoints"},
  [pscustomobject]@{No=29;Epic="Admin Module";TaskName="Admin AI behavior monitoring";Scope="Admin web + mobile";Platform="Backend + Web + Mobile";MainRole="Admin";Priority="Medium";Status="Done";KeyDeliverables="Review AI behavior logs and monitor chatbot/recommendation interactions";SourceReference="frontend/pages/admin/AIBehaviorLogs.jsx; mobile_app/app/admin/ai-logs.tsx; backend/src/routes/aiBehaviorLogRoutes.js";Notes="Operational AI governance"},
  [pscustomobject]@{No=30;Epic="Manager Module";TaskName="Manager dashboard KPI view";Scope="Manager web + mobile";Platform="Backend + Web + Mobile";MainRole="Manager";Priority="High";Status="Done";KeyDeliverables="Manager stats endpoint and manager dashboard screen";SourceReference="backend/src/routes/managerRoutes.js; frontend/pages/manager/ManagerDashboard.jsx; mobile_app/app/manager/dashboard.tsx";Notes="Mobile manager currently focuses on dashboard"},
  [pscustomobject]@{No=31;Epic="Manager Module";TaskName="Manager product operations";Scope="Manager web";Platform="Backend + Web";MainRole="Manager";Priority="High";Status="Done";KeyDeliverables="Manager product list, create, update, delete";SourceReference="backend/src/routes/managerRoutes.js; frontend/pages/manager/ManagerProducts.jsx";Notes="Uses dedicated manager namespace"},
  [pscustomobject]@{No=32;Epic="Manager Module";TaskName="Manager order oversight";Scope="Manager web";Platform="Backend + Web";MainRole="Manager";Priority="High";Status="Done";KeyDeliverables="Manager order listing and operational review";SourceReference="backend/src/routes/managerRoutes.js; frontend/pages/manager/ManagerOrders.jsx";Notes="Read-heavy managerial function"},
  [pscustomobject]@{No=33;Epic="Manager Module";TaskName="Manager category maintenance";Scope="Manager web";Platform="Backend + Web";MainRole="Manager";Priority="Medium";Status="Done";KeyDeliverables="Maintain categories through manager screens and APIs";SourceReference="frontend/pages/manager/ManagerCategories.jsx; backend/src/routes/categoryRoutes.js";Notes="Shared category data with admin"},
  [pscustomobject]@{No=34;Epic="Manager Module";TaskName="Manager reports and inventory visibility";Scope="Manager web";Platform="Backend + Web";MainRole="Manager";Priority="High";Status="Done";KeyDeliverables="Top products, revenue by category, customer stats, inventory reporting";SourceReference="backend/src/routes/managerRoutes.js; frontend/pages/manager/ManagerReports.jsx";Notes="Separate report namespace from admin"},
  [pscustomobject]@{No=35;Epic="Staff Module";TaskName="Staff dashboard and order queue";Scope="Staff operations";Platform="Backend + Web + Mobile";MainRole="Staff";Priority="High";Status="Done";KeyDeliverables="Staff stats, staff order list, staff dashboard screens";SourceReference="backend/src/routes/staffRoutes.js; frontend/pages/staff/StaffDashboard.jsx; mobile_app/app/staff/dashboard.tsx";Notes="Mobile staff currently focuses on dashboard visibility"},
  [pscustomobject]@{No=36;Epic="Staff Module";TaskName="Staff order status update and low-stock monitoring";Scope="Store operations";Platform="Backend";MainRole="Staff";Priority="High";Status="Done";KeyDeliverables="Update order status by staff and fetch low-stock products";SourceReference="backend/src/routes/staffRoutes.js; backend/src/controllers/staffControllers.js";Notes="Operational fulfillment support"},
  [pscustomobject]@{No=37;Epic="Mobile";TaskName="Mobile customer shopping flow";Scope="Mobile storefront";Platform="Mobile";MainRole="Guest/User";Priority="High";Status="Done";KeyDeliverables="Home, shop, product detail, cart, order, bestseller, about, contact";SourceReference="mobile_app/app/index.tsx; mobile_app/app/shop/index.tsx; mobile_app/app/product/[id].tsx; mobile_app/app/cart.tsx; mobile_app/app/order.tsx";Notes="Core mobile shopping app"},
  [pscustomobject]@{No=38;Epic="Mobile";TaskName="Mobile admin operations";Scope="Mobile admin";Platform="Mobile";MainRole="Admin";Priority="High";Status="Done";KeyDeliverables="Admin layout, dashboard, users, products, categories, orders, reports, AI logs";SourceReference="mobile_app/app/admin/_layout.tsx; mobile_app/app/admin/dashboard.tsx; mobile_app/app/admin/users.tsx";Notes="Documented in ADMIN_FLOW.md"},
  [pscustomobject]@{No=39;Epic="Platform Support";TaskName="Swagger documentation and request logging";Scope="Developer support";Platform="Backend";MainRole="Team";Priority="Medium";Status="Done";KeyDeliverables="Swagger UI, server request logging, error handling middleware";SourceReference="backend/src/config/swagger.js; backend/src/server.js";Notes="Improves maintainability and testing"},
  [pscustomobject]@{No=40;Epic="Platform Support";TaskName="Seed scripts and infrastructure configuration";Scope="Bootstrap";Platform="Backend";MainRole="Team";Priority="Medium";Status="Done";KeyDeliverables="DB connection, email config, seed admin, seed manager, seed staff";SourceReference="backend/src/config/db.js; backend/src/config/email.js; backend/src/scripts/seedAdmin.js; backend/src/scripts/seedManager.js; backend/src/scripts/seedStaff.js";Notes="Supports environment setup"}
)

$apiRows = @(
  [pscustomobject]@{No=1;Module="Auth";BaseRoute="/api/users and /api";Operations="register, login, me, update me, change password";AuthRequired="Mixed";MainRoles="Guest/User";RouteFile="backend/src/routes/authRoutes.js";Notes="Back-compat aliases for /api/register and /api/login"},
  [pscustomobject]@{No=2;Module="Users";BaseRoute="/api/users";Operations="list, detail, update, delete";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/userRoutes.js";Notes="Mounted behind admin auth middleware"},
  [pscustomobject]@{No=3;Module="Roles";BaseRoute="/api/roles";Operations="CRUD, add permissions, remove permission";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/rolesRoutes.js";Notes="Role-permission mapping support"},
  [pscustomobject]@{No=4;Module="Permissions";BaseRoute="/api/permissions";Operations="CRUD";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/permissionsRoutes.js";Notes="Used by permission middleware"},
  [pscustomobject]@{No=5;Module="User Roles";BaseRoute="/api/users/:id/roles";Operations="get user roles, assign roles, remove role";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/userRoleRoutes.js";Notes="Administrative RBAC assignment"},
  [pscustomobject]@{No=6;Module="Products";BaseRoute="/api/products";Operations="list, best-sellers, detail, create, update, delete";AuthRequired="Mixed";MainRoles="Guest/User/Admin/Manager";RouteFile="backend/src/routes/productsRoutes.js";Notes="Public read, protected write"},
  [pscustomobject]@{No=7;Module="Categories";BaseRoute="/api/categories";Operations="list, detail, create, update, delete";AuthRequired="Mixed";MainRoles="Guest/Admin/Manager";RouteFile="backend/src/routes/categoryRoutes.js";Notes="Create/update/delete require manager or admin"},
  [pscustomobject]@{No=8;Module="Reviews";BaseRoute="/api/reviews";Operations="get by product, get mine, can review, create/update/delete, admin list/detail";AuthRequired="Mixed";MainRoles="User/Admin";RouteFile="backend/src/routes/reviewRoutes.js";Notes="Customer review workflow"},
  [pscustomobject]@{No=9;Module="Recommendations";BaseRoute="/api/recommendations";Operations="admin CRUD, generate";AuthRequired="Yes";MainRoles="User/Admin";RouteFile="backend/src/routes/aiRecommendationRoutes.js";Notes="Generate endpoint available to authenticated users"},
  [pscustomobject]@{No=10;Module="Chatbot";BaseRoute="/api/chatbot";Operations="chat, get history";AuthRequired="Yes";MainRoles="User";RouteFile="backend/src/routes/chatbotRoutes.js";Notes="Gemini-backed conversation"},
  [pscustomobject]@{No=11;Module="Chatbot Logs";BaseRoute="/api/chatbot-logs";Operations="CRUD";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/chatbotLogRoutes.js";Notes="Mounted with admin requirement in server"},
  [pscustomobject]@{No=12;Module="AI Behavior Logs";BaseRoute="/api/ai-behavior-logs";Operations="create, get mine, admin list/detail/delete";AuthRequired="Yes";MainRoles="User/Admin";RouteFile="backend/src/routes/aiBehaviorLogRoutes.js";Notes="Audit trail for AI interactions"},
  [pscustomobject]@{No=13;Module="Carts";BaseRoute="/api/carts";Operations="get my cart, list, detail, create, update, delete";AuthRequired="Yes";MainRoles="User";RouteFile="backend/src/routes/cartRoutes.js";Notes="Includes my-cart shortcut"},
  [pscustomobject]@{No=14;Module="Cart Items";BaseRoute="/api/cart-items";Operations="list, detail, create, update, delete";AuthRequired="Yes";MainRoles="User";RouteFile="backend/src/routes/cartItemRoutes.js";Notes="Works with cart records"},
  [pscustomobject]@{No=15;Module="Orders";BaseRoute="/api/orders";Operations="get my orders, cancel, list, detail, create, update, delete";AuthRequired="Yes";MainRoles="User/Admin/Staff";RouteFile="backend/src/routes/orderRoutes.js";Notes="Write access partly permission-based"},
  [pscustomobject]@{No=16;Module="Order Items";BaseRoute="/api/order-items";Operations="CRUD";AuthRequired="Yes";MainRoles="Admin/Staff";RouteFile="backend/src/routes/orderItemRoutes.js";Notes="Protected by manage_orders permission"},
  [pscustomobject]@{No=17;Module="Payments";BaseRoute="/api/payments";Operations="CRUD";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/paymentRoutes.js";Notes="Administrative payment records"},
  [pscustomobject]@{No=18;Module="VNPay";BaseRoute="/api/vnpay";Operations="create payment URL, return, ipn";AuthRequired="Mixed";MainRoles="User/System";RouteFile="backend/src/routes/vnpayRoutes.js";Notes="Gateway-specific flow"},
  [pscustomobject]@{No=19;Module="Admin Stats";BaseRoute="/api/admin/stats";Operations="admin summary";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/adminRoutes.js";Notes="Separate from generic dashboard stats"},
  [pscustomobject]@{No=20;Module="Dashboard Stats";BaseRoute="/api/stats/dashboard";Operations="dashboard KPI data";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/statsRoutes.js";Notes="Used by web and mobile admin dashboards"},
  [pscustomobject]@{No=21;Module="Reports";BaseRoute="/api/reports";Operations="sales, top-products, revenue-by-category, customers, inventory";AuthRequired="Yes";MainRoles="Admin";RouteFile="backend/src/routes/reportRoutes.js";Notes="Admin analytics namespace"},
  [pscustomobject]@{No=22;Module="Manager";BaseRoute="/api/manager";Operations="stats, orders, products CRUD, reports";AuthRequired="Yes";MainRoles="Manager";RouteFile="backend/src/routes/managerRoutes.js";Notes="Role-specific business operations"},
  [pscustomobject]@{No=23;Module="Staff";BaseRoute="/api/staff";Operations="stats, orders, update status, low-stock products";AuthRequired="Yes";MainRoles="Staff";RouteFile="backend/src/routes/staffRoutes.js";Notes="Store execution workflow"}
)

$screenRows = @(
)

$excel = $null
$workbook = $null

try {
  $excel = New-Object -ComObject Excel.Application
  $excel.Visible = $false
  $excel.DisplayAlerts = $false
  $workbook = $excel.Workbooks.Add()

  while ($workbook.Worksheets.Count -lt 4) {
    [void]$workbook.Worksheets.Add()
  }

  $overviewSheet = $workbook.Worksheets.Item(1)
  $taskSheet = $workbook.Worksheets.Item(2)
  $apiSheet = $workbook.Worksheets.Item(3)
  $screenSheet = $workbook.Worksheets.Item(4)

  $overviewSheet.Name = "Overview"
  $taskSheet.Name = "Task List"
  $apiSheet.Name = "API Matrix"
  $screenSheet.Name = "Screen Map"
}
finally {
  if ($workbook -ne $null) {
    $workbook.Close($false)
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
  }
  if ($excel -ne $null) {
    $excel.Quit()
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
  }
  [GC]::Collect()
  [GC]::WaitForPendingFinalizers()
}
