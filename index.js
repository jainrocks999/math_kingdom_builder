class LearnArray {
  arr = [-2, 5, 0, 8, -1, 10];
  findSum = () => {
    let result = 0;
    for (let i = 0; i < this.arr.length; i++) {
      result += this.arr[i];
    }
    return result;
  };

  findEvenNumbers() {
    let result = [];
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] % 2 == 0) {
        result.push(this.arr[i]);
      }
    }
    return result;
  }
  findOddNumbers() {
    let result = [];
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] % 2 == 1) {
        result.push(this.arr[i]);
      }
    }
    return result;
  }
  findLargestNumber() {
    let result = this.arr[0];
    for (let i = 1; i < this.arr.length; i++) {
      if (this.arr[i] > result) {
        result = this.arr[i];
      }
    }
    return result;
  }
  findSmallestNumber() {
    let result = this.arr[0];
    for (let i = 1; i < this.arr.length; i++) {
      if (this.arr[i] < result) {
        result = this.arr[i];
      }
    }
    return result;
  }
  countEvenNumbers() {
    let result = 0;
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] % 2 === 0) {
        result++;
      }
    }
    return result;
  }
  countOddNumbers() {
    let result = 0;
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] % 2 === 1) {
        result++;
      }
    }
    return result;
  }
  countPositiveNumbers() {
    let result = 0;
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] > 0) {
        result++;
      }
    }
    return result;
  }
  countNegativeNumbers() {
    let result = 0;
    for (let i = 0; i < this.arr.length; i++) {
      if (this.arr[i] < 0) {
        result++;
      }
    }
    return result;
  }
  countZeros(arr) {
    let result = 0;
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] === 0) {
        result++;
      }
    }
    return result;
  }

  checkNumberExists(arr, target) {
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] === target) {
        return true;
      }
    }
    return false;
  }
  findNumberIndex(arr, target) {
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] === target) {
        return i;
      }
    }
    return -1;
  }
  countTarget(arr, target) {
    let result = 0;
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] === target) {
        result++;
      }
    }
    return result;
  }
  findAverage(arr) {
    let result = 0;
    if (arr.length === 0) {
      return 0;
    }
    for (let i = 0; i < arr.length; i++) {
      result += arr[i];
    }
    return result / arr.length;
  }

  findProduct(arr) {
    if (arr.length === 0) {
      return 0;
    }
    let result = 1;

    for (let i = 0; i < arr.length; i++) {
      result *= arr[i];
    }
    return result;
  }
  doubleNumbers(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      result.push(arr[i] * 2);
    }
    return result;
  }
  squareNumbers(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      result.push(arr[i] * arr[i]);
    }
    return result;
  }
  getNumbersLessThan10(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      if (arr[i] < 10) result.push(arr[i]);
    }
    return result;
  }
  getZeros(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      if (arr[i] == 0) result.push(arr[i]);
    }
    return result;
  }
  convertToNegative(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      if (arr[i] < 0) {
        result.push(arr[i]);
      } else {
        result.push(-arr[i]);
      }
    }
    return result;
  }
  convertToPositive(arr) {
    if (arr.length === 0) {
      return [];
    }
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      if (arr[i] < 0) {
        result.push(arr[i] * -1);
      } else {
        result.push(arr[i]);
      }
    }
    return result;
  }

  reverseArray = (arr) => {
    let result = [];
    for (let i = arr.length - 1; i >= 0; i--) {
      result.push(arr[i]);
    }
    return result;
  };
  findSecondLargest = (arr) => {
    let largest = -Infinity;
    let secondLargest = -Infinity;
    for (const number of arr) {
      if (number > largest) {
        secondLargest = largest;
        largest = number;
      } else if (number > secondLargest && number !== largest) {
        secondLargest = number;
      }
    }
  };
  findSecondSmallest = (arr) => {
    let smallest = Infinity;
    let secondSmallest = Infinity;
    for (const number of arr) {
      if (number < smallest) {
        secondSmallest = smallest;
        smallest = number;
      } else if (number < secondSmallest && number !== smallest) {
        secondSmallest = number;
      }
    }
    if (secondSmallest === Infinity) {
      return null;
    }

    return secondSmallest;
  };

  removeDuplicates(arr) {
    let result = [];
    for (const number of arr) {
      if (result.includes(number)) {
        continue;
      } else {
        result.push(number);
      }
    }
    return result;
  }
  findDuplicates(arr) {
    let result = [];
    for (let i = 0; i < arr.length; i++) {
      for (let j = i + 1; j < arr.length; j++) {
        if (arr[i] === arr[j]) {
          if (!result.includes(arr[j])) {
            result.push(arr[j]);
          }
        }
      }
    }
    return result;
  }

  findDuplicatesOptimized(arr) {
    let freq = {};
    let result = [];
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]]) {
        freq[arr[i]]++;
      } else {
        freq[arr[i]] = 1;
      }
    }
    for (let key in freq) {
      if (freq[key] > 1) {
        result.push(Number(key));
      }
    }
    return result;
  }

  countFrequency(arr) {
    let freq = {};

    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]]) {
        freq[arr[i]]++;
      } else {
        freq[arr[i]] = 1;
      }
    }
    return freq;
  }
  findFirstDuplicate(arr) {
    for (let i = 0; i < arr.length; i++) {
      for (let j = 0; j < i; j++) {
        if (arr[i] === arr[j]) {
          return arr[i];
        }
      }
    }
    return null;
  }

  findFirstDuplicateOptimized(arr) {
    let freq = {};
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]]) {
        return arr[i];
      } else {
        freq[arr[i]] = 1;
      }
    }
    return null;
  }
  findFirstNonRepeating(arr) {
    for (let i = 0; i < arr.length; i++) {
      let repeated = false;
      for (let j = 0; j < arr.length; j++) {
        if (arr[i] === arr[j] && i !== j) {
          repeated = true;
          break;
        }
      }
      if (!repeated) {
        return arr[i];
      }
    }
    return null;
  }
  findFirstNonRepeatingOptimized(arr) {
    let freq = {};
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]]) {
        freq[arr[i]]++;
      } else {
        freq[arr[i]] = 1;
      }
    }

    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]] === 1) {
        return arr[i];
      }
    }
    return null;
  }
  findLastDuplicate(arr) {
    let resul = null;

    for (let i = 0; i < arr.length; i++) {
      let dup = false;
      for (let j = 0; j < arr.length; j++) {
        if (arr[i] == arr[j] && i !== j) {
          dup = true;
          break;
        }
      }
      if (dup) {
        resul = arr[i];
      }
    }
    return resul;
  }
  findLastDuplicateOptimized(arr) {
    let freq = {};
    let result = null;
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]]) {
        freq[arr[i]]++;
      } else {
        freq[arr[i]] = 1;
      }
    }
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]] > 1) {
        result = arr[i];
      }
    }
    return result;
  }
  findLastNonRepeating(arr) {
    let result = null;
    for (let i = 0; i < arr.length; i++) {
      let reaped = false;
      for (let j = 0; j < arr.length; j++) {
        if (arr[i] === arr[j] && i !== j) {
          reaped = true;
          break;
        }
      }
      if (!reaped) {
        result = arr[i];
      }
    }
    return result;
  }
  findLastNonRepeatingOptimized(arr) {
    let freq = {};
    let result = null;
    for (let i = 0; i < arr.length; i++) {
      freq[arr[i]] = (freq[arr[i]] || 0) + 1;
    }
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]] === 1) {
        result = arr[i];
      }
    }
    return result;
  }
  getUniqueValues(arr) {
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      let reapeted = false;
      for (let j = 0; j < arr.length; j++) {
        if (arr[i] === arr[j] && i !== j) {
          reapeted = true;
          break;
        }
      }
      if (!reapeted) {
        result.push(arr[i]);
      }
    }
    return result;
  }
  getUniqueValuesOptimized(arr) {
    let freq = {};
    let result = [];
    for (let i = 0; i < arr.length; i++) {
      freq[arr[i]] = (freq[arr[i]] || 0) + 1;
      for (let i = 0; i < arr.length; i++) {
        if (freq[arr[i]] > 1) {
          result.push(arr[i]);
        }
      }
    }
    return result;
  }
  getRepeatedValues(arr) {
    let result = [];

    for (let i = 0; i < arr.length; i++) {
      let reapeted = false;
      for (let j = 0; j < arr.length; j++) {
        if (arr[i] === arr[j] && i !== j) {
          reapeted = true;
          break;
        }
      }
      if (reapeted && !result.includes(arr[i])) {
        result.push(arr[i]);
      }
    }
    return result;
  }
  getRepeatedValuesOptimized(arr) {
    let freq = {};
    let result = [];
    for (let i = 0; i < arr.length; i++) {
      freq[arr[i]] = (freq[arr[i]] || 0) + 1;
    }
    for (let i = 0; i < arr.length; i++) {
      if (freq[arr[i]] > 1 && !result.includes(arr[i])) {
        result.push(arr[i]);
      }
    }
    return result;
  }
  findMinMax(arr) {
    if (arr.length === 0) return null;
    let min = arr[0];
    let max = arr[0];
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] < min) {
        min = arr[i];
      }
      if (arr[i] > max) {
        max = arr[i];
      }
    }
    return {
      min,
      max,
    };
  }

  mergeUnique(arr1, arr2) {
    let newarray = [...arr1, ...arr2];
    let result = [];

    for (let i = 0; i < newarray.length; i++) {
      if (!result.includes(newarray[i])) {
        result.push(newarray[i]);
      }
    }
    return result;
  }
  mergeUniqueOptimized(arr1, arr2) {
    let seen = {};
    let result = [];
    let merged = [...arr1, ...arr2];

    for (let i = 0; i < merged.length; i++) {
      if (!seen[merged[i]]) {
        result.push(merged[i]);
        seen[merged[i]] = true;
      }
    }

    return result;
  }

  findIntersection(arr1, arr2) {
    let obj = {};
    let result = [];
    for (let i = 0; i < arr1.length; i++) {
      obj[arr1[i]] = true;
    }
    for (let i = 0; i < arr2.length; i++) {
      if (obj[arr2[i]]) {
        result.push(arr2[i]);
      }
    }
    return result;
  }
}
const arraInstance = new LearnArray();

const arr = [10, 5, 30, 8, 20];
const arr1 = [1, 1, 2, 3, 4];
const arr2 = [3, 4, 5, 6];

console.log(arraInstance.findIntersection(arr1, arr2));
