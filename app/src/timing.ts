const endTiming = <T>(start: Date, result: T, type: any): T => {
  const end: Date = new Date();
  const duration: number = end.getTime() - start.getTime();
  // tslint:disable-next-line:no-console
  console.log("TIMING: %s", JSON.stringify({type, start, end, durationMillis: duration}));
  return result;
}

export const withTiming = <T>(f: () => Promise<T>, type: any): Promise<T> => {
  const start = new Date();
  const result = f();
  if (result && "then" in result) {
    return result.finally(() => {
      return endTiming(start, null, type);
    });
  }

  return endTiming(start, result, type);
}
