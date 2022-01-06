Config["Documents"]["public"] = {
    {
        headerTitle = "AFFIRMATION FORM",
        headerSubtitle = "Citizen affirmation form.",
        elements = {
            { label = "AFFIRMATION CONTENT", type = "textarea", value = "", can_be_emtpy = false },
        },
    },
    {
        headerTitle = "WITNESS TESTIMONY",
        headerSubtitle = "Official witness testimony.",
        elements = {
            { label = "DATE OF OCCURENCE", type = "input", value = "", can_be_emtpy = false },
            { label = "TESTIMONY CONTENT", type = "textarea", value = "", can_be_emtpy = false },
        },
    },
    {
        headerTitle = "VEHICLE CONVEY STATEMENT",
        headerSubtitle = "Vehicle convey statement towards another citizen.",
        elements = {
            { label = "PLATE NUMBER", type = "input", value = "", can_be_emtpy = false },
            { label = "CITIZEN NAME", type = "input", value = "", can_be_emtpy = false },
            { label = "AGREED PRICE", type = "input", value = "", can_be_empty = false },
            { label = "OTHER INFORMATION", type = "textarea", value = "", can_be_emtpy = true },
        },
    },
    {
        headerTitle = "DEBT STATEMENT TOWARDS CITIZEN",
        headerSubtitle = "Official debt statement towards another citizen.",
        elements = {
            { label = "CREDITOR FIRSTNAME", type = "input", value = "", can_be_emtpy = false },
            { label = "CREDITOR LASTNAME", type = "input", value = "", can_be_emtpy = false },
            { label = "AMOUNT DUE", type = "input", value = "", can_be_empty = false },
            { label = "DUE DATE", type = "input", value = "", can_be_empty = false },
            { label = "OTHER INFORMATION", type = "textarea", value = "", can_be_emtpy = true },
        },
    },
    {
        headerTitle = "DEBT CLEARANCE DECLARATION",
        headerSubtitle = "Declaration of debt clearance from another citizen.",
        elements = {
            { label = "DEBTOR FIRSTNAME", type = "input", value = "", can_be_emtpy = false },
            { label = "DEBTOR LASTNAME", type = "input", value = "", can_be_emtpy = false },
            { label = "DEBT AMOUNT", type = "input", value = "", can_be_empty = false },
            { label = "OTHERINFORMATION", type = "textarea", value = "I HEREBY DECLARE THAT THE AFOREMENTIONED CITIZEN HAS COMPLETED A PAYMENT WITH THE AFOREMENTIONED DEBT AMOUNT", can_be_emtpy = false, can_be_edited = false },
        },
    },
}