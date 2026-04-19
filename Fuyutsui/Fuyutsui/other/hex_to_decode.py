import binascii

# 原始的加密字符串
hex_data = "..." 

# 这里替换为你文件里的长字符串

# 1. 按照映射表还原标准的十六进制
mapping = str.maketrans("NOKY", "DFBA")
standard_hex = hex_data.translate(mapping)

# 2. 将十六进制转为文本
try:
    decoded_code = binascii.unhexlify(standard_hex).decode('utf-8', errors='ignore')
    with open("Decoded_WeakAuras.lua", "w", encoding="utf-8") as f:
        f.write(decoded_code)
    print("解密完成，已保存为 Decoded_WeakAuras.lua")
except Exception as e:
    print("转换失败，请检查字符串完整性:", e)