#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
检查数字文件是否包含完整且不重复的 1~max 整数序列
"""

import os
import sys

def check_numbers(file_path):
    """
    检查指定文件中的数字是否完全充满1~max且不重复
    
    参数:
        file_path: 数字文件的路径
        
    返回:
        (bool, str): 检查结果和详细信息
    """
    try:
        # 检查文件是否存在
        if not os.path.exists(file_path):
            return False, f"错误: 文件 '{file_path}' 不存在"
            
        # 读取文件内容
        numbers = []
        with open(file_path, 'r') as file:
            for line in file:
                line = line.strip()
                if line:  # 跳过空行
                    try:
                        num = int(line)
                        numbers.append(num)
                    except ValueError:
                        return False, f"错误: 文件包含非整数值 '{line}'"
        
        if not numbers:
            return False, "错误: 文件为空或不包含有效整数"
            
        # 找出最大值
        max_num = max(numbers)
        
        # 检查是否所有数字都在1~max范围内
        if min(numbers) < 1:
            return False, f"错误: 文件包含小于1的数字"
            
        # 检查是否有重复
        if len(numbers) != len(set(numbers)):
            # 找出重复的数字
            duplicates = [num for num in numbers if numbers.count(num) > 1]
            duplicates = sorted(set(duplicates))
            return False, f"错误: 文件包含重复数字: {duplicates}"
            
        # 检查是否包含所有1~max的数字
        missing_numbers = []
        for i in range(1, max_num + 1):
            if i not in numbers:
                missing_numbers.append(i)
                
        # 检查数量是否正确
        if missing_numbers:
            return False, f"错误: 文件包含 {len(numbers)} 个数字，但最大值是 {max_num}，缺少的数字: {missing_numbers}"
                
        return True, f"成功: 文件包含完整且不重复的1~{max_num}整数序列"
        
    except Exception as e:
        return False, f"错误: {str(e)}"

def main():
    """主函数"""
    # 默认检查当前目录下的numbers.txt
    default_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "numbers.txt")
    
    # 允许通过命令行参数指定其他文件
    file_path = sys.argv[1] if len(sys.argv) > 1 else default_file
    
    # 执行检查
    result, message = check_numbers(file_path)
    
    # 输出结果
    print(message)
    
    # 返回状态码 (0表示成功, 1表示失败)
    return 0 if result else 1

if __name__ == "__main__":
    sys.exit(main())
