import { TopComponent } from "shared/types";
import { getTopComponents } from "../../api/topComponents";
import { useDatasetContext } from "../../../contexts/DatasetContext";
import { AnalyticsParams } from "shared/types";
import { createResource, For, Show } from "solid-js";
import { MagicSuspense } from "../../../components/MagicBox";

interface TopComponentsProps {
  params: Pick<AnalyticsParams, "filter">;
}

export const TopComponents = (props: TopComponentsProps) => {
  const datasetContext = useDatasetContext();
  const dataset = datasetContext?.dataset;

  const [topComponents] = createResource(
    () => ({
      filter: props.params.filter,
      datasetId: dataset?.id || "",
    }),
    async ({ filter, datasetId }) => {
      if (!datasetId) return [];
      return await getTopComponents(filter, datasetId);
    }
  );

  return (
    <MagicSuspense fallback={<div>Loading top components...</div>}>
      <div class="flex flex-col space-y-4 py-2">
        <Show when={!topComponents.loading && topComponents()?.length === 0}>
          <div class="text-center text-gray-500 dark:text-gray-400">
            No component interactions found in the selected time period.
          </div>
        </Show>
        <Show when={!topComponents.loading && topComponents()?.length}>
          <div class="overflow-x-auto">
            <table class="w-full text-left">
              <thead>
                <tr class="border-b border-gray-200 dark:border-gray-700">
                  <th class="pb-2 text-sm font-normal text-gray-500 dark:text-gray-400">
                    Component
                  </th>
                  <th class="pb-2 text-right text-sm font-normal text-gray-500 dark:text-gray-400">
                    Interactions
                  </th>
                </tr>
              </thead>
              <tbody>
                <For each={topComponents()}>
                  {(component: TopComponent) => (
                    <tr class="border-b border-gray-100 dark:border-gray-800">
                      <td class="py-3 text-sm font-medium">
                        {component.component_name}
                      </td>
                      <td class="py-3 text-right text-sm">
                        {component.interaction_count.toLocaleString()}
                      </td>
                    </tr>
                  )}
                </For>
              </tbody>
            </table>
          </div>
        </Show>
      </div>
    </MagicSuspense>
  );
};