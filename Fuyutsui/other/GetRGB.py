import pyautogui
from PIL import ImageGrab
import time

def get_mouse_rgb():
    """获取鼠标当前位置的RGB颜色值"""
    try:
        # 获取鼠标位置
        x, y = pyautogui.position()
        
        # 获取屏幕截图并提取该像素的RGB值
        screenshot = ImageGrab.grab(bbox=(x, y, x+1, y+1))
        rgb = screenshot.getpixel((0, 0))
        
        return x, y, rgb
    except Exception as e:
        print(f"错误: {e}")
        return None, None, None

def main():
    """主函数：每秒获取并打印鼠标位置的RGB"""
    print("开始监控鼠标位置的RGB值...")
    print("按 Ctrl+C 停止")
    print("-" * 50)
    
    try:
        while True:
            x, y, rgb = get_mouse_rgb()
            if rgb:
                r, g, b = rgb
                print(f"位置: ({x}, {y}) | RGB: ({r}, {g}, {b})")
            time.sleep(0.5)  # 等待1秒
    except KeyboardInterrupt:
        print("\n程序已停止")

if __name__ == "__main__":
    main()
