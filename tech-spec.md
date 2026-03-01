# 营养补剂跟踪器 - 技术规范

---

## 1. 组件清单

### shadcn/ui 内置组件

| 组件 | 用途 | 安装命令 |
|------|------|----------|
| Button | 各类按钮 | `npx shadcn add button` |
| Card | 统计卡片、补剂卡片 | `npx shadcn add card` |
| Dialog | 添加/编辑模态框 | `npx shadcn add dialog` |
| Drawer | 移动端抽屉 | `npx shadcn add drawer` |
| Form | 表单处理 | `npx shadcn add form` |
| Input | 文本输入 | `npx shadcn add input` |
| Label | 表单标签 | `npx shadcn add label` |
| Select | 下拉选择 | `npx shadcn add select` |
| Switch | 开关控件 | `npx shadcn add switch` |
| Tabs | 标签页切换 | `npx shadcn add tabs` |
| Badge | 状态徽章 | `npx shadcn add badge` |
| Progress | 进度条 | `npx shadcn add progress` |
| Alert | 提醒通知 | `npx shadcn add alert` |
| Dropdown Menu | 下拉菜单 | `npx shadcn add dropdown-menu` |
| Calendar | 日期选择 | `npx shadcn add calendar` |
| Popover | 弹出层 | `npx shadcn add popover` |
| Separator | 分割线 | `npx shadcn add separator` |
| Skeleton | 加载骨架 | `npx shadcn add skeleton` |
| Tooltip | 工具提示 | `npx shadcn add tooltip` |
| Scroll Area | 滚动区域 | `npx shadcn add scroll-area` |

### 第三方组件

| 组件 | 来源 | 用途 |
|------|------|------|
| Number Ticker | @magicui/number-ticker | 数字计数动画 |
| Animated Beam | @magicui/animated-beam | 连接线动画 |

### 自定义组件

| 组件 | 用途 | 位置 |
|------|------|------|
| StatCard | 统计概览卡片 | `app/components/stat-card.tsx` |
| SupplementCard | 补剂列表卡片 | `app/components/supplement-card.tsx` |
| SupplementForm | 补剂表单 | `app/components/supplement-form.tsx` |
| CostChart | 花费趋势图 | `app/components/cost-chart.tsx` |
| CategoryChart | 分类占比图 | `app/components/category-chart.tsx` |
| EmptyState | 空状态 | `app/components/empty-state.tsx` |
| ReminderItem | 提醒项 | `app/components/reminder-item.tsx` |

---

## 2. 动画实现方案

### 动画库选择

| 动画类型 | 库 | 理由 |
|----------|-----|------|
| 页面过渡 | Framer Motion | React原生支持，API友好 |
| 滚动动画 | Framer Motion (useInView) | 与组件集成度高 |
| 数字动画 | @magicui/number-ticker | 专用数字动画组件 |
| 图表动画 | Recharts 内置 | 图表自带动画 |
| 微交互 | Framer Motion | 悬停、点击反馈 |

### 动画实现表

| 动画 | 库 | 实现方式 | 复杂度 |
|------|-----|----------|--------|
| 页面加载淡入 | Framer Motion | AnimatePresence + motion.div | 中 |
| 统计卡片依次弹出 | Framer Motion | staggerChildren + variants | 中 |
| 数字计数动画 | @magicui/number-ticker | 直接使用组件 | 低 |
| 滚动触发显示 | Framer Motion | useInView + motion | 中 |
| 卡片悬停效果 | Framer Motion | whileHover | 低 |
| 按钮悬停效果 | Tailwind CSS | hover: 类 | 低 |
| 模态框滑入 | Framer Motion | AnimatePresence + motion | 中 |
| 进度条动画 | Framer Motion | animate prop | 低 |
| 列表项进入 | Framer Motion | staggerChildren | 中 |
| 空状态浮动 | Framer Motion | animate + repeat | 低 |

### 缓动函数定义

```typescript
// lib/animations.ts
export const easings = {
  outQuart: [0.165, 0.840, 0.440, 1],
  spring: [0.34, 1.56, 0.64, 1],
  easeOut: [0, 0, 0.2, 1],
};

export const transitions = {
  default: {
    duration: 0.5,
    ease: easings.outQuart,
  },
  fast: {
    duration: 0.2,
    ease: easings.easeOut,
  },
  spring: {
    type: "spring",
    stiffness: 300,
    damping: 25,
  },
};

export const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -20 },
};

export const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.08,
    },
  },
};
```

---

## 3. 项目结构

```
my-app/
├── app/
│   ├── components/
│   │   ├── stat-card.tsx
│   │   ├── supplement-card.tsx
│   │   ├── supplement-form.tsx
│   │   ├── cost-chart.tsx
│   │   ├── category-chart.tsx
│   │   ├── empty-state.tsx
│   │   ├── reminder-item.tsx
│   │   ├── navbar.tsx
│   │   └── footer.tsx
│   ├── hooks/
│   │   ├── use-supplements.ts
│   │   ├── use-statistics.ts
│   │   └── use-local-storage.ts
│   ├── lib/
│   │   ├── utils.ts
│   │   ├── animations.ts
│   │   └── calculations.ts
│   ├── types/
│   │   └── index.ts
│   ├── page.tsx
│   ├── layout.tsx
│   └── globals.css
├── components/
│   └── ui/           # shadcn组件
├── public/
├── next.config.js
├── tailwind.config.ts
└── package.json
```

---

## 4. 依赖安装

### 核心依赖

```bash
# 动画库
npm install framer-motion

# 图表库
npm install recharts

# 日期处理
npm install date-fns

# 图标
npm install lucide-react

# 表单处理
npm install react-hook-form @hookform/resolvers zod
```

### shadcn 组件

```bash
npx shadcn add button card dialog drawer form input label select switch tabs badge progress alert dropdown-menu calendar popover separator skeleton tooltip scroll-area
```

### MagicUI 组件

```bash
npx shadcn add @magicui/number-ticker
```

---

## 5. 数据类型定义

```typescript
// types/index.ts

export interface Supplement {
  id: string;
  name: string;
  specification: string;  // 规格，如 "1000mg, 60粒"
  dailyDosage: number;    // 每日服用量
  dosageUnit: string;     // 单位：粒/片/滴
  intakeTimes: string[];  // 服用时间：["morning", "evening"]
  price: number;          // 购买价格
  purchaseDate: string;   // 购买日期 ISO
  totalQuantity: number;  // 总数量
  remainingQuantity: number; // 剩余数量
  category: string;       // 分类
  notes?: string;         // 备注
  reminderEnabled: boolean; // 是否开启提醒
  lowStockThreshold: number; // 库存不足阈值
}

export interface DailyRecord {
  date: string;
  supplementId: string;
  taken: boolean;
  takenAt?: string;
}

export interface Statistics {
  totalSupplements: number;
  dailyCost: number;
  monthlyCost: number;
  yearlyCost: number;
  avgRemainingDays: number;
  shortestRemainingDays: number;
  categoryBreakdown: Record<string, number>;
  monthlyTrend: { month: string; cost: number }[];
}

export interface Reminder {
  id: string;
  type: 'low_stock' | 'purchase' | 'intake' | 'system';
  title: string;
  message: string;
  supplementId?: string;
  createdAt: string;
  read: boolean;
}
```

---

## 6. 核心计算逻辑

```typescript
// lib/calculations.ts

import { Supplement } from '@/app/types';
import { differenceInDays, parseISO, format } from 'date-fns';

// 计算每日花费
export function calculateDailyCost(supplement: Supplement): number {
  const daysSupply = supplement.totalQuantity / supplement.dailyDosage;
  return supplement.price / daysSupply;
}

// 计算剩余天数
export function calculateRemainingDays(supplement: Supplement): number {
  return Math.floor(supplement.remainingQuantity / supplement.dailyDosage);
}

// 计算预计用完日期
export function calculateDepletionDate(supplement: Supplement): string {
  const remainingDays = calculateRemainingDays(supplement);
  const depletionDate = new Date();
  depletionDate.setDate(depletionDate.getDate() + remainingDays);
  return format(depletionDate, 'yyyy-MM-dd');
}

// 计算总统计
export function calculateStatistics(supplements: Supplement[]): Statistics {
  const dailyCost = supplements.reduce((sum, s) => sum + calculateDailyCost(s), 0);
  const monthlyCost = dailyCost * 30;
  const yearlyCost = dailyCost * 365;
  
  const remainingDays = supplements.map(calculateRemainingDays);
  const avgRemainingDays = remainingDays.length > 0 
    ? remainingDays.reduce((a, b) => a + b, 0) / remainingDays.length 
    : 0;
  const shortestRemainingDays = remainingDays.length > 0 
    ? Math.min(...remainingDays) 
    : 0;

  // 分类统计
  const categoryBreakdown: Record<string, number> = {};
  supplements.forEach(s => {
    const cost = calculateDailyCost(s) * 30;
    categoryBreakdown[s.category] = (categoryBreakdown[s.category] || 0) + cost;
  });

  return {
    totalSupplements: supplements.length,
    dailyCost,
    monthlyCost,
    yearlyCost,
    avgRemainingDays: Math.round(avgRemainingDays),
    shortestRemainingDays,
    categoryBreakdown,
    monthlyTrend: [], // 需要历史数据
  };
}
```

---

## 7. 本地存储方案

```typescript
// hooks/use-local-storage.ts

import { useState, useEffect } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(initialValue);
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      try {
        const item = window.localStorage.getItem(key);
        if (item) {
          setStoredValue(JSON.parse(item));
        }
      } catch (error) {
        console.error('Error reading from localStorage:', error);
      }
      setIsInitialized(true);
    }
  }, [key]);

  const setValue = (value: T) => {
    try {
      setStoredValue(value);
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(key, JSON.stringify(value));
      }
    } catch (error) {
      console.error('Error writing to localStorage:', error);
    }
  };

  return [storedValue, setValue];
}
```

---

## 8. 颜色配置

```typescript
// tailwind.config.ts 扩展

const config = {
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#3ebb7f',
          dark: '#339968',
          light: '#e8f5ee',
        },
        neutral: {
          black: '#1d1d1d',
          'dark-grey': '#5a5a5a',
          grey: '#8a8a8a',
          'light-grey': '#f5f5f5',
          white: '#ffffff',
        },
        border: '#e5e5e5',
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
      },
      borderRadius: {
        'card': '12px',
        'button': '10px',
      },
      boxShadow: {
        'card': '0 1px 3px rgba(0,0,0,0.05), 0 4px 12px rgba(0,0,0,0.05)',
        'card-hover': '0 4px 12px rgba(0,0,0,0.08), 0 8px 24px rgba(0,0,0,0.06)',
      },
    },
  },
};
```

---

## 9. 性能优化

### 图片优化
- 使用 Next.js Image 组件
- 图标使用 Lucide React (SVG)
- 无需外部图片资源

### 动画优化
- 使用 `transform` 和 `opacity`
- 添加 `will-change` 提示
- 支持 `prefers-reduced-motion`

### 代码优化
- 组件懒加载
- 使用 React.memo 优化列表
- 本地存储数据压缩

---

## 10. 开发顺序

1. 项目初始化 + 依赖安装
2. 类型定义 + 本地存储 hook
3. 核心计算逻辑
4. 基础组件 (Navbar, Footer)
5. 统计卡片组件
6. 补剂列表 + 卡片组件
7. 添加/编辑表单
8. 数据图表
9. 动画效果
10. 响应式适配
11. 测试 + 优化
12. 构建部署
