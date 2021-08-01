const endTiming = (start: Date, result: any, type: any) => {
  const end: Date = new Date();
  const duration: number = end.getTime() - start.getTime();
  // tslint:disable-next-line:no-console
  console.log("TIMING: %s", JSON.stringify({
    type,
    start,
    end,
    durationMillis: duration
  }));
  return result;
}

export const withTiming = (f: any, type: any) => {
  const start = new Date();
  const result = f();
  if (result && result.then) {
    return result.finally((value: any) => {
      return endTiming(start, value, type);
    });
  }

  return endTiming(start, result, type);
}
